'reach 0.1';

/*
1. PROBLEM ANALYSIS
 Who is involved in this application?
 (1) Locker, Alice
 (2) Unlocker, Bob
 What information do they know at the start of the program?
 Alice:
 (1) Amount to be locked
 (2) Secret password
 Bob:
 (0) Knows nothing
 What information are they going to discover during the application and how?
 (1) Contract info
 Alice:
 Doesn't learn anyghing
 Bob:
 Learns password
 - Contract info will be published by Alice, which is provided to
   Bob to attach. 
 What funds change ownership ownership during the application and how?
 - Funds are transfered from Alice to Bob by way of contract
 + Releasing the funds to Bob requires a correct secret password
 Alice transfers fund at the start of the program
 Bob recieves fund after learning password
2. DATA DEFINITION
What data type will represent the amount Alice transfers?
Unsighted Int, UInt
What data type will represent Alice's password?
Array of characters, char[]?
What participant interact interface will each participant use?
*/

export const main = Reach.App(
  { deployMode: 'firstMsg' },
  [Participant('Alice', { amt: UInt, pass: UInt }),
  Participant('Bob', { getPass: Fun([], UInt) })],
  (Alice, Bob) => {
    // 3. Communication Construction
    // 4. Assertion Insertion
    // 5. Interaction Introduction
    // 6. Deployment decisions ...
    // Alice publishes a digest of the password and pays amount
    Alice.only(() => {
      const _pass = interact.pass
      const [amt, passDigest] =
        declassify([interact.amt,
        digest(_pass)]);
    });
    Alice.publish(passDigest, amt)
      .pay(amt);
    commit();

    // ASSERT passA digest only known to Alice
    unknowable(Bob, Alice(_pass)); // Bob knows nothing

    // Bob publishes password
    // ASSERT Bob assumes passB digest matches passA digest
    Bob.only(() => {
      const pass = declassify(interact.getPass())
      assume(passDigest == digest(pass));
    }) // Bob is honest
    Bob.publish(pass);
    // The consensus ensures it's the right password and pays Bob
    /*
    const outcome = passA == passB
    const [forA, forB] = 
      outcome ? [0, 1] :
      [0, 1];
    transfer(forA * amt).to(Alice)
    transfer(forB * amt).to(Bob)
    */
    // ASSERT passA == passB
    require(passDigest == digest(pass), "Digests actually match")
    transfer(amt).to(Bob)
    commit();

    exit(); 
  });
