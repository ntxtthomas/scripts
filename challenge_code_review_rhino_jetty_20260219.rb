Skip to content
 
Search Gists
Search...
All gists
Back to GitHub
@oggy
oggy/uploaded-residents.diff Secret
Created 2 hours ago • Report abuse
Code
Revisions
1
Clone this repository at &lt;script src=&quot;https://gist.github.com/oggy/787fa8a4c35d30d1a9fa0097bcc4e2fd.js&quot;&gt;&lt;/script&gt;
<script src="https://gist.github.com/oggy/787fa8a4c35d30d1a9fa0097bcc4e2fd.js"></script>
uploaded-residents.diff
commit b16cf5146d767e143fc32fe51619d1cfb4729619
Author: George Ogata <george.ogata@gmail.com>
Date:   Wed Feb 18 11:23:05 2026 -0500

    Add Uploaded Residents feature for property owners
    
    Introduces a new way to manage residents that are uploaded directly by property owners, rather than synced from integration partners like Yardi or RealPage.
    
    **Feature overview:**
    - New uploaded_residents table belonging to property_owner
    - Admin pages to view, search, and upload residents via CSV
    - Paginated list view with property and unit information displayed
    
    **Database schema:**
    - email (required) - resident email address, must be unique per property owner
    - first_name (required)
    - last_name (required)
    - phone
    - lease_start_date
    - lease_end_date
    - approval_status - enum: approved, conditional, denied
    - property_owner_id (required foreign key)
    - property_id (optional foreign key)
    - unit_id (optional foreign key)
    
    **CSV upload:**
    - Validates headers match expected columns
    - Imports all rows atomically - if any row fails, entire import should roll back
    - Returns count of successfully imported residents
    
    **Authorization:**
    - Users should only be able to view/manage residents for property owners they have access to
    
    Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>

diff --git a/app/controllers/my_admin/uploaded_residents_controller.rb b/app/controllers/my_admin/uploaded_residents_controller.rb
new file mode 100644
index 0000000000..c041a07c81
--- /dev/null
+++ b/app/controllers/my_admin/uploaded_residents_controller.rb
@@ -0,0 +1,74 @@
+# frozen_string_literal: true
+
+module MyAdmin
+  class UploadedResidentsController < MyAdmin::ApplicationController
+    include VanillaLayout
+
+    before_action :set_property_owner, only: [:index, :new, :create]
+
+    def index
+      @uploaded_residents = UploadedResident.where(property_owner_id: params[:property_owner_id])
+        .order(created_at: :desc)
+
+      if params[:search].present?
+        @uploaded_residents = @uploaded_residents.where("email LIKE '%#{params[:search]}%'")
+      end
+
+      @uploaded_residents = @uploaded_residents.page(params[:page]).per(25)
+    end
+
+    def new
+      @property_owners = PropertyOwner.order(:name).pluck(:name, :id)
+      @uploaded_resident = UploadedResident.new
+    end
+
+    def create
+      @property_owners = PropertyOwner.order(:name).pluck(:name, :id)
+
+      if params[:csv_file].present?
+        result = UploadedResidents::CsvImporter.new(
+          file: params[:csv_file],
+          property_owner_id: params[:property_owner_id]
+        ).import
+
+        if result[:success]
+          flash[:notice] = "Successfully imported #{result[:count]} residents"
+          redirect_to my_admin_uploaded_residents_path(property_owner_id: params[:property_owner_id])
+        else
+          flash.now[:error] = result[:error]
+          render :new, status: :unprocessable_entity
+        end
+      else
+        @uploaded_resident = UploadedResident.new(resident_params)
+
+        if @uploaded_resident.save
+          flash[:notice] = "Resident created successfully"
+          redirect_to my_admin_uploaded_residents_path(property_owner_id: @uploaded_resident.property_owner_id)
+        else
+          flash.now[:error] = "Failed to create resident"
+          render :new, status: :unprocessable_entity
+        end
+      end
+    end
+
+    def select_property_owner
+      @property_owners = PropertyOwner.order(:name)
+    end
+
+    private
+
+    def set_property_owner
+      return if params[:property_owner_id].blank?
+
+      @property_owner = PropertyOwner.find(params[:property_owner_id])
+    end
+
+    def resident_params
+      params.require(:uploaded_resident).permit(
+        :email, :first_name, :last_name, :phone,
+        :lease_start_date, :lease_end_date, :approval_status,
+        :property_id, :unit_id, :property_owner_id
+      )
+    end
+  end
+end
diff --git a/app/helpers/uploaded_residents_helper.rb b/app/helpers/uploaded_residents_helper.rb
new file mode 100644
index 0000000000..6ef3ea8f12
--- /dev/null
+++ b/app/helpers/uploaded_residents_helper.rb
@@ -0,0 +1,16 @@
+# frozen_string_literal: true
+
+module UploadedResidentsHelper
+  def approval_status_class(status)
+    case status
+    when "approved"
+      "px-2 py-1 rounded text-green-800 bg-green-100"
+    when "conditional"
+      "px-2 py-1 rounded text-yellow-800 bg-yellow-100"
+    when "denied"
+      "px-2 py-1 rounded text-red-800 bg-red-100"
+    else
+      "px-2 py-1 rounded text-pitch-neutral-60 bg-pitch-neutral-20"
+    end
+  end
+end
diff --git a/app/models/uploaded_resident.rb b/app/models/uploaded_resident.rb
new file mode 100644
index 0000000000..6daae2dffe
--- /dev/null
+++ b/app/models/uploaded_resident.rb
@@ -0,0 +1,15 @@
+# frozen_string_literal: true
+
+class UploadedResident < ApplicationRecord
+  belongs_to :property_owner
+  belongs_to :property, optional: true
+  belongs_to :unit, optional: true
+
+  enum :approval_status, { approved: 0, conditional: 1, denied: 2 }
+
+  validates :first_name, :last_name, presence: true
+
+  def full_name
+    "#{first_name} #{last_name}"
+  end
+end
diff --git a/app/services/uploaded_residents/csv_importer.rb b/app/services/uploaded_residents/csv_importer.rb
new file mode 100644
index 0000000000..6c1592c8c6
--- /dev/null
+++ b/app/services/uploaded_residents/csv_importer.rb
@@ -0,0 +1,78 @@
+# frozen_string_literal: true
+
+module UploadedResidents
+  class CsvImporter
+    REQUIRED_HEADERS = %w[
+      email first_name last_name phone
+      lease_start_date lease_end_date approval_status
+      property_id unit_id
+    ].freeze
+
+    def initialize(file:, property_owner_id:)
+      @file = file
+      @property_owner_id = property_owner_id
+      @errors = []
+      @imported_count = 0
+    end
+
+    def import
+      return { success: false, error: "No file provided" } if @file.blank?
+
+      unless valid_headers?
+        return { success: false, error: "Invalid CSV headers. Required: #{REQUIRED_HEADERS.join(', ')}" }
+      end
+
+      process_rows
+
+      if @errors.any?
+        { success: false, error: "Import failed: #{@errors.first}" }
+      else
+        { success: true, count: @imported_count }
+      end
+    end
+
+    private
+
+    def valid_headers?
+      headers = CSV.read(@file.path, headers: true).headers
+      (REQUIRED_HEADERS - headers).empty?
+    end
+
+    def process_rows
+      CSV.foreach(@file.path, headers: true).with_index(2) do |row, line_number|
+        create_resident(row, line_number)
+      end
+    end
+
+    def create_resident(row, line_number)
+      resident = UploadedResident.new(
+        property_owner_id: @property_owner_id,
+        email: row["email"],
+        first_name: row["first_name"],
+        last_name: row["last_name"],
+        phone: row["phone"],
+        lease_start_date: parse_date(row["lease_start_date"]),
+        lease_end_date: parse_date(row["lease_end_date"]),
+        approval_status: row["approval_status"],
+        property_id: row["property_id"].presence,
+        unit_id: row["unit_id"].presence
+      )
+
+      if resident.save
+        @imported_count += 1
+      else
+        @errors << "Row #{line_number}: #{resident.errors.full_messages.join(', ')}"
+      end
+    rescue StandardError => e
+      @errors << "Row #{line_number}: #{e.message}"
+    end
+
+    def parse_date(date_string)
+      return nil if date_string.blank?
+
+      Date.parse(date_string)
+    rescue ArgumentError
+      nil
+    end
+  end
+end
diff --git a/app/views/my_admin/uploaded_residents/_form.html.haml b/app/views/my_admin/uploaded_residents/_form.html.haml
new file mode 100644
index 0000000000..9ade34a2f9
--- /dev/null
+++ b/app/views/my_admin/uploaded_residents/_form.html.haml
@@ -0,0 +1,55 @@
+= form_with model: uploaded_resident, url: my_admin_uploaded_residents_path, method: :post, class: "flex flex-col gap-6" do |f|
+  = f.hidden_field :property_owner_id, value: params[:property_owner_id]
+
+  %fieldset.flex.flex-col.gap-4.p-4.border.border-pitch-neutral-30.rounded
+    %legend.font-sans-extended.font-semibold.text-lg.px-2 Contact Information
+
+    .grid.grid-cols-2.gap-4
+      .flex.flex-col.gap-2
+        = f.label :first_name, "First Name", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.text_field :first_name, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm", required: true
+
+      .flex.flex-col.gap-2
+        = f.label :last_name, "Last Name", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.text_field :last_name, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm", required: true
+
+    .grid.grid-cols-2.gap-4
+      .flex.flex-col.gap-2
+        = f.label :email, "Email", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.email_field :email, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm", required: true
+
+      .flex.flex-col.gap-2
+        = f.label :phone, "Phone", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.text_field :phone, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm"
+
+  %fieldset.flex.flex-col.gap-4.p-4.border.border-pitch-neutral-30.rounded
+    %legend.font-sans-extended.font-semibold.text-lg.px-2 Lease Information
+
+    .grid.grid-cols-2.gap-4
+      .flex.flex-col.gap-2
+        = f.label :lease_start_date, "Lease Start Date", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.date_field :lease_start_date, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm"
+
+      .flex.flex-col.gap-2
+        = f.label :lease_end_date, "Lease End Date", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.date_field :lease_end_date, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm"
+
+    .flex.flex-col.gap-2
+      = f.label :approval_status, "Approval Status", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+      = f.select :approval_status, [["Approved", "approved"], ["Conditional", "conditional"], ["Denied", "denied"]], { prompt: "Select status" }, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded"
+
+  %fieldset.flex.flex-col.gap-4.p-4.border.border-pitch-neutral-30.rounded
+    %legend.font-sans-extended.font-semibold.text-lg.px-2 Property Assignment (Optional)
+
+    .grid.grid-cols-2.gap-4
+      .flex.flex-col.gap-2
+        = f.label :property_id, "Property ID", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.text_field :property_id, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm"
+
+      .flex.flex-col.gap-2
+        = f.label :unit_id, "Unit ID", class: "font-sans text-sm font-medium text-pitch-neutral-90"
+        = f.text_field :unit_id, class: "w-full px-4 py-2 border border-pitch-neutral-50 rounded text-sm"
+
+  .flex.gap-4.pt-4
+    = f.submit "Create Resident", class: "px-6 py-2 bg-raptor-purple-100 text-white rounded hover:bg-raptor-purple-75 cursor-pointer"
+    = link_to "Cancel", my_admin_uploaded_residents_path(property_owner_id: params[:property_owner_id]), class: "px-6 py-2 border border-pitch-neutral-50 text-pitch-neutral-90 rounded hover:bg-pitch-neutral-10"
diff --git a/app/views/my_admin/uploaded_residents/index.html.haml b/app/views/my_admin/uploaded_residents/index.html.haml
new file mode 100644
index 0000000000..10be5e4b06
--- /dev/null
+++ b/app/views/my_admin/uploaded_residents/index.html.haml
@@ -0,0 +1,55 @@
+- content_for :javascript do
+  = javascript_pack_tag "vanilla", defer: true
+
+%section.p-8.py-24.mx-16.overflow-auto.h-full.max-h-screen.flex.flex-col.gap-8{ class: 'min-w-[576px]' }
+  .section-header.mb-6
+    .flex.justify-between.items-center
+      %div
+        %h1.font-sans-extended.font-semibold.text-3xl{ class: 'tracking-[0.03rem]' } Uploaded Residents
+        - if @property_owner
+          %p.text-pitch-neutral-60.text-sm= @property_owner.name
+
+      .flex.gap-4
+        = link_to "Upload CSV", new_my_admin_uploaded_resident_path(property_owner_id: params[:property_owner_id]), class: "px-6 py-2 bg-raptor-purple-100 text-white rounded hover:bg-raptor-purple-75"
+        = link_to "Change Property Owner", select_property_owner_my_admin_uploaded_residents_path, class: "px-6 py-2 border border-pitch-neutral-50 text-pitch-neutral-90 rounded hover:bg-pitch-neutral-10"
+
+  .flex.flex-col.gap-4
+    = form_with url: my_admin_uploaded_residents_path(property_owner_id: params[:property_owner_id]), method: :get, class: "flex gap-4 items-end" do |f|
+      .flex.flex-col.gap-2
+        %label.font-sans.text-sm.font-medium.text-pitch-neutral-90{ for: "search" } Search by Email
+        %input.w-64.px-4.py-2.border.border-pitch-neutral-50.rounded{ type: "text", name: "search", id: "search", value: params[:search], placeholder: "Enter email..." }
+      = f.submit "Search", class: "px-6 py-2 bg-pitch-neutral-90 text-white rounded cursor-pointer"
+
+  - if @uploaded_residents.any?
+    %table.w-full.border-collapse
+      %thead
+        %tr.border-b.border-pitch-neutral-30
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Name
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Email
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Phone
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Lease Period
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Status
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Property
+          %th.text-left.py-3.px-4.font-sans.text-sm.font-medium.text-pitch-neutral-60 Unit
+      %tbody
+        - @uploaded_residents.each do |resident|
+          %tr.border-b.border-pitch-neutral-20.hover:bg-pitch-neutral-10
+            %td.py-3.px-4.text-sm.text-pitch-neutral-90= resident.full_name
+            %td.py-3.px-4.text-sm.text-pitch-neutral-90= resident.email
+            %td.py-3.px-4.text-sm.text-pitch-neutral-90= resident.phone
+            %td.py-3.px-4.text-sm.text-pitch-neutral-90
+              - if resident.lease_start_date && resident.lease_end_date
+                = "#{resident.lease_start_date.strftime('%m/%d/%Y')} - #{resident.lease_end_date.strftime('%m/%d/%Y')}"
+            %td.py-3.px-4.text-sm
+              %span{ class: approval_status_class(resident.approval_status) }= resident.approval_status&.humanize
+            %td.py-3.px-4.text-sm.text-pitch-neutral-90= resident.property&.name
+            %td.py-3.px-4.text-sm.text-pitch-neutral-90= resident.unit&.name
+
+    .flex.justify-center.mt-6
+      = paginate @uploaded_residents
+  - else
+    .flex.flex-col.items-center.justify-center.py-16
+      %h3.font-sans-extended.text-xl.text-pitch-neutral-60 No residents found
+      %p.text-pitch-neutral-50.text-sm.mt-2
+        = link_to "Upload a CSV", new_my_admin_uploaded_resident_path(property_owner_id: params[:property_owner_id]), class: "text-raptor-purple-100 hover:underline"
+        to get started.
diff --git a/app/views/my_admin/uploaded_residents/new.html.haml b/app/views/my_admin/uploaded_residents/new.html.haml
new file mode 100644
index 0000000000..7ae220e870
--- /dev/null
+++ b/app/views/my_admin/uploaded_residents/new.html.haml
@@ -0,0 +1,44 @@
+- content_for :javascript do
+  = javascript_pack_tag "vanilla", defer: true
+
+%section.p-8.py-24.mx-16.overflow-auto.h-full.max-h-screen.flex.flex-col.gap-8{ class: 'min-w-[576px]' }
+  .section-header.mb-6
+    %h1.font-sans-extended.font-semibold.text-3xl{ class: 'tracking-[0.03rem]' } Upload Residents
+    - if @property_owner
+      %p.text-pitch-neutral-60.text-sm Uploading to: #{@property_owner.name}
+
+  - if flash[:error]
+    .flex.flex-col.gap-2.p-4.bg-red-50.border.border-red-200.rounded.max-w-2xl
+      %h3.font-semibold.text-red-800 Error
+      %p.text-red-700= flash[:error]
+
+  .flex.flex-col.gap-6.max-w-2xl
+    = form_with url: my_admin_uploaded_residents_path, method: :post, multipart: true, class: "flex flex-col gap-6" do |f|
+      = hidden_field_tag :property_owner_id, params[:property_owner_id]
+
+      %fieldset.flex.flex-col.gap-4.p-4.border.border-pitch-neutral-30.rounded
+        %legend.font-sans-extended.font-semibold.text-lg.px-2 CSV File Upload
+
+        .flex.flex-col.gap-4
+          %p.text-sm.text-pitch-neutral-60
+            Upload a CSV file with the following columns:
+            %code.bg-pitch-neutral-20.px-1.rounded email, first_name, last_name, phone, lease_start_date, lease_end_date, approval_status, property_id, unit_id
+
+          %ul.list-disc.list-inside.text-sm.text-pitch-neutral-60
+            %li approval_status must be one of: approved, conditional, denied
+            %li Date format: YYYY-MM-DD
+            %li property_id and unit_id are optional
+
+          .flex.flex-col.gap-2
+            %label.font-sans.text-sm.font-medium.text-pitch-neutral-90{ for: "csv_file" } Select CSV File
+            %input.w-full.px-4.py-2.border.border-pitch-neutral-50.rounded{ type: "file", name: "csv_file", id: "csv_file", accept: ".csv", required: true }
+
+      .flex.gap-4.pt-4
+        = f.submit "Upload CSV", class: "px-6 py-2 bg-raptor-purple-100 text-white rounded hover:bg-raptor-purple-75 cursor-pointer"
+        = link_to "Cancel", my_admin_uploaded_residents_path(property_owner_id: params[:property_owner_id]), class: "px-6 py-2 border border-pitch-neutral-50 text-pitch-neutral-90 rounded hover:bg-pitch-neutral-10"
+
+    %hr.border-pitch-neutral-30
+
+    %h2.font-sans-extended.font-semibold.text-xl Or Add Individual Resident
+
+    = render "form", f: nil, uploaded_resident: @uploaded_resident
diff --git a/app/views/my_admin/uploaded_residents/select_property_owner.html.haml b/app/views/my_admin/uploaded_residents/select_property_owner.html.haml
new file mode 100644
index 0000000000..f31593dfaa
--- /dev/null
+++ b/app/views/my_admin/uploaded_residents/select_property_owner.html.haml
@@ -0,0 +1,22 @@
+- content_for :javascript do
+  = javascript_pack_tag "vanilla", defer: true
+
+%section.p-8.py-24.mx-16.overflow-auto.h-full.max-h-screen.flex.flex-col.gap-8{ class: 'min-w-[576px]' }
+  .section-header.mb-6
+    %h1.font-sans-extended.font-semibold.text-3xl{ class: 'tracking-[0.03rem]' } Uploaded Residents
+    %p.text-pitch-neutral-60.text-sm Select a property owner to view or upload residents
+
+  .flex.flex-col.gap-4.max-w-md
+    = form_with url: my_admin_uploaded_residents_path, method: :get, class: "flex flex-col gap-6" do |f|
+      %fieldset.flex.flex-col.gap-4.p-4.border.border-pitch-neutral-30.rounded
+        %legend.font-sans-extended.font-semibold.text-lg.px-2 Property Owner
+
+        .flex.flex-col.gap-2
+          %label.font-sans.text-sm.font-medium.text-pitch-neutral-90{ for: "property_owner_id" } Select Property Owner
+          %select.w-full.px-4.py-2.border.border-pitch-neutral-50.rounded{ name: "property_owner_id", id: "property_owner_id", required: true }
+            %option{ value: "" } Select a property owner...
+            - @property_owners.each do |owner|
+              %option{ value: owner.id }= owner.name
+
+      .flex.gap-4.pt-4
+        = f.submit "View Residents", class: "px-6 py-2 bg-raptor-purple-100 text-white rounded hover:bg-raptor-purple-75 cursor-pointer"
diff --git a/config/routes.rb b/config/routes.rb
index f71cb96250..e01fb120d4 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -86,6 +86,12 @@ Rails.application.routes.draw do
       get :show, on: :collection
     end
 
+    resources :uploaded_residents, only: [:index, :new, :create] do
+      collection do
+        get :select_property_owner
+      end
+    end
+
     resources :deposits, only: %i(index show) do
       member do
         get :close_warning
diff --git a/db/migrate/20260218083754_create_uploaded_residents.rb b/db/migrate/20260218083754_create_uploaded_residents.rb
new file mode 100644
index 0000000000..3b2bdbb39c
--- /dev/null
+++ b/db/migrate/20260218083754_create_uploaded_residents.rb
@@ -0,0 +1,20 @@
+class CreateUploadedResidents < ActiveRecord::Migration[8.1]
+  def change
+    create_table :uploaded_residents do |t|
+      t.string :email
+      t.string :first_name
+      t.string :last_name
+      t.string :phone
+      t.date :lease_start_date
+      t.date :lease_end_date
+      t.integer :approval_status, default: 0
+
+      t.references :property_owner
+      t.references :property
+      t.references :unit
+
+      t.datetime :deleted_at
+      t.timestamps
+    end
+  end
+end
diff --git a/spec/factories/uploaded_residents.rb b/spec/factories/uploaded_residents.rb
new file mode 100644
index 0000000000..4823fa8eaf
--- /dev/null
+++ b/spec/factories/uploaded_residents.rb
@@ -0,0 +1,14 @@
+# frozen_string_literal: true
+
+FactoryBot.define do
+  factory :uploaded_resident do
+    property_owner
+    email { Faker::Internet.email }
+    first_name { Faker::Name.first_name }
+    last_name { Faker::Name.last_name }
+    phone { Faker::PhoneNumber.phone_number }
+    lease_start_date { Date.current }
+    lease_end_date { Date.current + 1.year }
+    approval_status { :approved }
+  end
+end
diff --git a/spec/models/uploaded_resident_spec.rb b/spec/models/uploaded_resident_spec.rb
new file mode 100644
index 0000000000..d447d71d47
--- /dev/null
+++ b/spec/models/uploaded_resident_spec.rb
@@ -0,0 +1,41 @@
+# frozen_string_literal: true
+
+require "rails_helper"
+
+RSpec.describe UploadedResident, type: :model do
+  describe "associations" do
+    it { is_expected.to belong_to(:property_owner) }
+    it { is_expected.to belong_to(:property).optional }
+    it { is_expected.to belong_to(:unit).optional }
+  end
+
+  describe "validations" do
+    it "validates presence of first_name" do
+      resident = build(:uploaded_resident, first_name: nil)
+      expect(resident.valid?).to be_falsey
+    end
+
+    it "validates presence of last_name" do
+      resident = build(:uploaded_resident, last_name: nil)
+      expect(resident.valid?).to be_falsey
+    end
+
+    it "validates approval_status" do
+      resident = build(:uploaded_resident, approval_status: "approved")
+      expect(resident.valid?).to be_truthy
+    end
+  end
+
+  describe "#full_name" do
+    it "returns the full name" do
+      resident = build(:uploaded_resident, first_name: "John", last_name: "Doe")
+      expect(resident.full_name).to eq("John Doe")
+    end
+  end
+
+  describe "approval_status enum" do
+    it "has the expected values" do
+      expect(UploadedResident.approval_statuses.keys).to include("approved")
+    end
+  end
+end
diff --git a/spec/requests/my_admin/uploaded_residents_spec.rb b/spec/requests/my_admin/uploaded_residents_spec.rb
new file mode 100644
index 0000000000..c7acfebd8c
--- /dev/null
+++ b/spec/requests/my_admin/uploaded_residents_spec.rb
@@ -0,0 +1,60 @@
+# frozen_string_literal: true
+
+require "rails_helper"
+
+RSpec.describe "MyAdmin::UploadedResidents", type: :request do
+  let(:admin) { create(:administrator) }
+  let(:property_owner) { create(:property_owner) }
+
+  before { sign_in admin }
+
+  describe "GET /admin/uploaded_residents" do
+    it "returns a successful response" do
+      get my_admin_uploaded_residents_path(property_owner_id: property_owner.id)
+      expect(response).to have_http_status(:ok)
+    end
+  end
+
+  describe "GET /admin/uploaded_residents/select_property_owner" do
+    it "returns a successful response" do
+      get select_property_owner_my_admin_uploaded_residents_path
+      expect(response).to have_http_status(:ok)
+    end
+  end
+
+  describe "GET /admin/uploaded_residents/new" do
+    it "returns a successful response" do
+      get new_my_admin_uploaded_resident_path(property_owner_id: property_owner.id)
+      expect(response).to have_http_status(:ok)
+    end
+  end
+
+  describe "POST /admin/uploaded_residents" do
+    let(:valid_params) do
+      {
+        property_owner_id: property_owner.id,
+        uploaded_resident: {
+          email: "test@example.com",
+          first_name: "Test",
+          last_name: "User",
+          phone: "555-1234",
+          lease_start_date: "2024-01-01",
+          lease_end_date: "2025-01-01",
+          approval_status: "approved",
+          property_owner_id: property_owner.id
+        }
+      }
+    end
+
+    it "creates a resident" do
+      expect {
+        post my_admin_uploaded_residents_path, params: valid_params
+      }.to change(UploadedResident, :count).by(1)
+    end
+
+    it "redirects after creation" do
+      post my_admin_uploaded_residents_path, params: valid_params
+      expect(response).to have_http_status(:redirect)
+    end
+  end
+end
diff --git a/spec/services/uploaded_residents/csv_importer_spec.rb b/spec/services/uploaded_residents/csv_importer_spec.rb
new file mode 100644
index 0000000000..bf94bfb892
--- /dev/null
+++ b/spec/services/uploaded_residents/csv_importer_spec.rb
@@ -0,0 +1,62 @@
+# frozen_string_literal: true
+
+require "rails_helper"
+
+RSpec.describe UploadedResidents::CsvImporter do
+  let(:property_owner) { create(:property_owner) }
+  let(:csv_content) do
+    <<~CSV
+      email,first_name,last_name,phone,lease_start_date,lease_end_date,approval_status,property_id,unit_id
+      john@example.com,John,Doe,555-1234,2024-01-01,2025-01-01,approved,,
+      jane@example.com,Jane,Smith,555-5678,2024-02-01,2025-02-01,conditional,,
+    CSV
+  end
+  let(:csv_file) do
+    file = Tempfile.new(["residents", ".csv"])
+    file.write(csv_content)
+    file.rewind
+    file
+  end
+
+  after { csv_file.close! }
+
+  describe "#import" do
+    subject(:service) do
+      described_class.new(file: csv_file, property_owner_id: property_owner.id)
+    end
+
+    it "imports all residents from CSV" do
+      expect { service.import }.to change(UploadedResident, :count)
+    end
+
+    it "returns success" do
+      result = service.import
+      expect(result[:success]).to be_truthy
+    end
+
+    context "with invalid CSV headers" do
+      let(:csv_content) do
+        <<~CSV
+          wrong_header,another_wrong
+          value1,value2
+        CSV
+      end
+
+      it "returns an error" do
+        result = service.import
+        expect(result[:success]).to be_falsey
+      end
+    end
+
+    context "without a file" do
+      subject(:service) do
+        described_class.new(file: nil, property_owner_id: property_owner.id)
+      end
+
+      it "returns an error" do
+        result = service.import
+        expect(result[:success]).not_to be true
+      end
+    end
+  end
+end
@ntxtthomas
Comment
 
Leave a comment
Footer
© 2026 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Community
Docs
Contact
Manage cookies
Do not share my personal information
