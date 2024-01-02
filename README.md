<h1><img src="Styling/PIC.png" width=80 height=80/><img src="Styling/PIC.svg" width=256 height=80/></h1>
<ul>
  <h2><img src="Styling/list.png" width=30 height=25/>  Table of contents:</h2>
  <ul>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-overview">Overview</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-sequence-of-operation">Sequence of operation</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-block-diagrams">Block diagrams</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-signals">Signals</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-simulation">Simulation</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-testbench-methodolgy">Testbench methodolgy</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-modifications">Modifications</a></li>
    <li><a href="https://github.com/AntiHexCode/PIC-8259A/tree/main?tab=readme-ov-file#-team-members">Team members and contribution</a></li>
  </ul>
  <details>
  <summary><img src="Styling/overview.png" width=30 height=30/><h2> Overview</h2></summary>
    <ul>
    <p>
      This project simulates 8259A PIC behavior using verilog, PIC is short for 
      <strong>P</strong>rogrammable <strong>I</strong>nterrupt <strong>C</strong>ontroller. The design
      was inspired from the <a href="https://drive.google.com/file/d/1ff_bdktK6zrH54DNJ6saOl5jdVz1-0MY/view?usp=drive_link">Intel datasheet</a> with some modifications.</p>
      <p>
      <storng>The design was divided into 4 major blocks as follows:</storng>
      <ul>
        <li>Control logic block</li>
        <li>Interrupt logic block</li>
        <li>Read Write logic block</li>
        <li>Cascade logic block</li>
      </ul>
    </p>
    <p>
      <strong>Our lovely PIC 8259A is designed to be:</strong>
      <ul>
        <li>8086 compatible</li>
        <li>Programmable</li>
        <li>Single +5V supply, no master clock</li>
        <li>Eight-Level Priority Controller</li>
        <li>Expandable to 64 Levels via cascading</li>
        <li>Handling interrupts in fully-nested mode/automatic roation</li>
        <li>Interrupt masking compatible</li>
        <li>EOI/AEOI supportive</li>
        <li>supportive for reading status</li>
      </ul>
    </p>
    </ul>
  </details>
  <details>
    <summary><img src="Styling/sequence.png" width=30 height=30/><h2> Sequence of operation</h2></summary>
    <ol>
        <li>All command words are sent from 8086 to the RW logic.</li>
        <li>RW logic parses the command words sending flags to control logic</li>
        <li>Whilst command words are being sent, all blocks are initializing according to the command words</li>
        <li>Once all command words are sent, other blocks can start working on the interrupt.</li>
        <li>Control logic triggers 8086 for interrupts</li>
        <li>Interrupt starts upon recieving the first INTA(active low) pulse, fetching the IRs</li>
        <li>Priority resolver chooses which request will be served taking into consideration various modes(fully-nested,rotation mode etc...)</li>
        <li>
          Control logic puts the vector address(from ISR) on the data bus upon recieving the second INTA pulse only if
          addressWrite flag is high (in single mode), in case of cascade mode, depending on current interrupt location,
          it would be put on the data bus by one of the slaves.
        </li>
        <li>8086 sends read signal, allowing to read ISR(current interrupt request in service), IRR and IMR</li>
    </ol>
  </details>
  <details>
    <summary><img src="Styling/blocks.png" width=30 height=30/><h2> Block diagrams</h2></summary>
    <ul>
      <img src="Read Write Control Logic/ControlLogicBlock.png" width=512 height=512/><p>Control logic block diagram, the mastermind of the PIC, takes flags from R/W logic, parses the data to give it to other blocks</p>
      <img src="Read Write Control Logic/RWLogic diagram.png" width=512 height=512/><p>Read write logic block diagram, this block deals with 8086 directly, recieving command words, writing them and sending flags to the control logic 
      to make all blocks initialize their states and work correctly.</p>
    </ul>
  </details>
  <details>
    <summary><img src="Styling/signals.png" width=30 height=30/><h2> Signals</h2></summary>
    <ul>
      <h3>Control logic signals (click on picture for better view)</h3>
       <img src="Read Write Control Logic/ControlLogicPorts.png"/>
    <h3>R/W logic signals</h3>
    <table>
      <tr>
        <th>Signal</th>
        <th>Description</th>
      </tr>
      <tr>
        <td>A0</td>
        <td>1 bit input from 8086, used to identify command words</td>
      </tr>
      <tr>
        <td>CS</td>
        <td>1 bit active low input from 8086, turns on the PIC or off</td>
      </tr>
      <tr>
        <td>WR</td>
        <td>1 bit active low input from 8086, when asserted, allows writing in RW logic</td>
      </tr>
      <tr>
        <td>RD</td>
        <td>1 bit active low input from 8086, when asserted, allows reading status of PIC</td>
      </tr>
      <tr>
        <td>Data Bus</td>
        <td>8 bit buffer, carries command words from 8086. Takes data from PIC to 8086. It is the main method of communication between 8086 and PIC</td>
      </tr>
      <tr>
        <td>rden</td>
        <td>1 bit output, used by control logic to let it know that read signal is asserted</td>
      </tr>
      <tr>
        <td>ICW1Flag</td>
        <td>1 bit output, a flag to indicate the current command word is ICW1</td>
      </tr>
      <tr>
        <td>ICW2Flag</td>
        <td>1 bit output, a flag to indicate the current command word is ICW2</td>
      </tr>
      <tr>
        <td>ICW3Flag</td>
        <td>1 bit output, a flag to indicate the current command word is ICW3</td>
      </tr>
      <tr>
        <td>ICW4Flag</td>
        <td>1 bit output, a flag to indicate the current command word is ICW4</td>
      </tr>
      <tr>
        <td>OCW1Flag</td>
        <td>1 bit output, a flag to indicate the current command word is OCW1</td>
      </tr>
      <tr>
        <td>OCW2Flag</td>
        <td>1 bit output, a flag to indicate the current command word is OCW2</td>
      </tr>
      <tr>
        <td>OCW3Flag</td>
        <td>1 bit output, a flag to indicate the current command word is OCW3</td>
      </tr>
    </table>
  </ul>
  </details>
  <details>
    <summary><img src="Styling/simmulation.png" width=30 height=30/><h2> Simulation</h2></summary>
    <h3>R/W logic simualtion</h3>
    <table>
      <tr>
        <th></th>
        <th></th>
      </tr>
      <tr>
        <td><img src="Read Write Control Logic/all command words.png"/> All command words written</td>
        <td><img src="Read Write Control Logic/ICW3 and ICW4 Missing.png"/>ICW3 and ICW4 aren't written</td>
      </tr>
      <tr>
        <td><img src="Read Write Control Logic/ICW3 Missing.png"/>ICW3 isn't written</td>
        <td><img src="Read Write Control Logic/ICW4 Missing.png"/>ICW4 isn't written</td>
      </tr>
    </table>
    <h3>Control logic simulation</h3>
    <table>
      <tr>
        <th></th>
        <th></th>
      </tr>
      <tr>
        <td><img src="Read Write Control Logic/ControlLogicTBSim1.png"/></td>
        <td><img src="Read Write Control Logic/ControlLogicTBSim2.png"/></td>
      </tr>
      <tr>
        <td><img src="Read Write Control Logic/ControlLogicTBSim3.png"/></td>
        <td><img src="Read Write Control Logic/ControlLogicTBSim4.png"/></td>
      </tr>
      <tr>
        <td><img src="Read Write Control Logic/ControlLogicTBSim5.png"/></td>
        <td><img src="Read Write Control Logic/ControlLogicTBSim6.png"/></td>
      </tr>
    </table>
  </details>
  <details>
    <summary><img src="Styling/test.png" width=30 height=30/><h2> Testbench methodolgy</h2></summary>
  </details>
  <details>
    <summary><img src="Styling/modification.png" width=30 height=30/><h2> Modifications</h2></summary>
    <ul>
      <li>R/W logic works with an internal clock, since the command words need some form of sequence to operate, a clock was needed to enhance and ease the design of the logic of command words</li>
      <li>All blocks won't start working unless all command words are sent</li>
      <li>8086 must send all OCWs to facilitate the design of the blocks</li>
      <li>RW logic takes some of the control logic tasks such as parsing the data for command words and sends them to contorl logic</li>
      <li>Control logic and R/W logic can be reduced to one single complex block</li>
      <li>Interrupt logic block recieves the acknowledgement (INTA) directly from 8086</li>
      <li>Control logic sets the 8 bit vector address on the data bus not the ISR</li>
      <li>Control logic is responsible for reading the status of PIC, in exchange of R/W logic parsing the data and setting flags.</li>
    </ul>
  </details>
  <details>
    <summary><img src="Styling/group-users.png" width=30 height=30/><h2> Team members</h2></summary>
    <ul>
    <table>
      <tr>
        <th>Name</th>
        <th>ID</th>
        <th>GitHub username</th>
        <th>Contribution</th>
      </tr>
      <tr>
        <td>Abdullah Mohammed</td>
        <td>2001803</td>
        <td><a href="https://github.com/AntiHexCode">AntiHexCode</a></td>
        <td>Control logic, Read Logic, PIC8259A</td>
      </tr>
      <tr>
        <td>Ahmad Mahfouz</td>
        <td>2002238</td>
        <td><a href="https://github.com/rye141200">rye141200</a></td>
        <td>Write logic(Read write block),PIC8259A</td>
      </tr>
      <tr>
        <td>Mohammed Mostafa</td>
        <td>2001299</td>
        <td><a href="https://github.com/mohamed-most">mohamed-most</a></td>
        <td>Interrupt logic (ISR, IRR,Priority resolver)</td>
      </tr>
    </table>
    </ul>
  </details>
</ul>
