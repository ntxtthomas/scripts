import { useState } from 'react';

function Toggle() {
  const [isOn, setIsOn] = useState(true);

  function handleClick() {
    setIsOn(!isOn);
  }

  return (
    <button onClick={handleClick}>
      {isOn ? 'ON' : 'OFF'}
    </button>
  );
}

export default Toggle;


# OR

import React, { useState } from 'react';

const Toggle = () => {
  const [on, setOn] = useState(true);

  return (
    <button onClick={() => setOn(!on)}>{ on ? 'ON' : 'OFF' }</button>
  );
}
export default Toggle;


