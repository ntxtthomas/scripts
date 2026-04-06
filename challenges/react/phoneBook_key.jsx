// We provided some simple React template code. Your goal is to create a simple form at the
// top that allows the user to enter in a first name, last name, and phone number and there
// should be a submit button. Once the submit button is pressed, the information should be
// displayed in a list below (automatically sorted by last name) along with all the
// previous information that was entered. This way the application can function as a simple
// phone book.
// - You should not allow submit to be pressed if any of the input fields are empty.
// When your application loads, the input fields (not the phone book list) should be prepopulated
// with the following values already:
// ```
// First name = Coder
// Last name = Byte
// Phone = 8885559999
// ```
// You are free to add classes and styles, but make sure you leave the component ID's and classes provided as they are.
// Submit your code once it is complete and our system will validate your output.




import React, { useState } from "react";
import { createRoot } from "react-dom/client";

const style = {
  table: {
    borderCollapse: "collapse",
  },
  tableCell: {
    border: "1px solid gray",
    margin: 0,
    padding: "5px 10px",
    width: "max-content",
    minWidth: "150px",
  },
  form: {
    container: {
      padding: "20px",
      border: "1px solid #F0F8FF",
      borderRadius: "15px",
      width: "max-content",
      marginBottom: "40px",
    },
    inputs: {
      marginBottom: "5px",
    },
    submitBtn: {
      marginTop: "10px",
      padding: "10px 15px",
      border: "none",
      backgroundColor: "lightseagreen",
      fontSize: "14px",
      borderRadius: "5px",
    },
  },
};

function PhoneBookForm({ addEntryToPhoneBook }) {
  const [firstName, setFirstName] = useState("Coder");
  const [lastName, setLastName] = useState("Byte");
  const [phone, setNewPhone] = useState("8885559999");

  const handleSubmit = (e) => {
    e.preventDefault();
    const newContact = {
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    };

    addEntryToPhoneBook(newContact);
    setFirstName("Coder");
    setLastName("Byte");
    setNewPhone("8885559999");
  };

  return (
    <form onSubmit={handleSubmit} style={style.form.container}>
      <label>First name:</label>
      <br />
      <input
        style={style.form.inputs}
        className="userFirstname"
        name="userFirstname"
        type="text"
        value={firstName}
        onChange={(e) => setFirstName(e.target.value)}
      />
      <br />
      <label>Last name:</label>
      <br />
      <input
        style={style.form.inputs}
        className="userLastname"
        name="userLastname"
        type="text"
        value={lastName}
        onChange={(e) => setLastName(e.target.value)}
      />
      <br />
      <label>Phone:</label>
      <br />
      <input
        style={style.form.inputs}
        className="userPhone"
        name="userPhone"
        type="text"
        value={phone}
        onChange={(e) => setNewPhone(e.target.value)}
      />
      <br />
      <input
        style={style.form.submitBtn}
        className="submitButton"
        type="submit"
        value="Add User"
        disabled={firstName === "" || lastName === "" || phone === ""}
      />
    </form>
  );
}

function InformationTable({ contacts }) {
  return (
    <table style={style.table} className="informationTable">
      <thead>
        <tr>
          <th style={style.tableCell}>First name</th>
          <th style={style.tableCell}>Last name</th>
          <th style={style.tableCell}>Phone</th>
        </tr>
      </thead>
      <tbody>
        {contacts.map((contact, index) => (
          <tr key={index}>
            <td>{contact.firstName}</td>
            <td>{contact.lastName}</td>
            <td>{contact.phone}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function Application(props) {
  const [contacts, setContacts] = useState([]);

  function addEntryToPhoneBook(newContact) {
    const newContacts = [...contacts, newContact];
    const sortedContacts = newContacts.sort((a, b) =>
      a.lastName.localeCompare(b.lastName)
    );
    setContacts(sortedContacts);
  }

  return (
    <section>
      <PhoneBookForm addEntryToPhoneBook={addEntryToPhoneBook} />
      <InformationTable contacts={contacts} />
    </section>
  );
}

export default Application;


// What you accomplished:
// ✅ State management - Multiple useState hooks, lifting state up
// ✅ Controlled components - Form inputs tied to state
// ✅ Form validation - Disabled submit button when fields empty
// ✅ Event handling - Form submission with preventDefault
// ✅ Props and data flow - Parent to child communication
// ✅ Array rendering - Using map to display dynamic lists
// ✅ Form reset - Back to prepopulated values after submit
// ✅ Data sorting - Automatic alphabetical sorting by last name
// ✅ Component architecture - Clean separation of concerns

// Key React concepts you mastered:
// State hooks and setter functions
// Controlled vs uncontrolled components
// Props destructuring and passing
// Event handling patterns
// Array methods in JSX (map)
// Component composition
// Data flow principles
// From a learning perspective:
// You tackled this methodically, debugged syntax errors, made architectural decisions, and 
// implemented a complete feature. This shows real growth in React thinking!

// These patterns you've learned here (state management, form handling, list rendering, data 
// flow) are the foundation of most React applications.
