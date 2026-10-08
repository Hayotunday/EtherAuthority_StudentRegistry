# StudentRegistry Smart Contracts

An on-chain student registration system built on a secure two-step ownership pattern. The contract owner can register students with a name and ID, remove them, and anyone can query registration status or student details. Built with [Remix IDE](https://remix.ethereum.org/) using Solidity `^0.8.20`.

## Contracts

### `Ownable` (`contracts/Ownable.sol`)

A standalone ownership contract implementing a secure two-step ownership transfer pattern. The deployer becomes the initial owner.

**State Variables**
| Variable | Visibility | Description |
|---|---|---|
| `_owner` | `private` | Current contract owner |
| `_pendingOwner` | `private` | Address that has been proposed but has not yet accepted ownership |

**Events**
| Event | Description |
|---|---|
| `OwnershipTransferred(previousOwner, newOwner)` | Emitted when ownership is successfully transferred |
| `OwnershipTransferStarted(previousOwner, newOwner)` | Emitted when a new pending owner is proposed |

**Custom Errors**
| Error | Description |
|---|---|
| `Ownable__UnauthorizedAccount(address account)` | Caller is not the owner |
| `Ownable__OwnerCannotBeBurnAddress()` | Attempted to transfer ownership to the zero address |
| `Ownable__NotPendingOwner()` | Caller is not the pending owner |

**Functions**
| Function | Visibility | Description |
|---|---|---|
| `constructor()` | — | Sets `msg.sender` as the initial owner |
| `owner()` | `view` | Returns the current owner address |
| `pendingOwner()` | `view` | Returns the pending owner address (if any) |
| `transferOwnership(address newOwner)` | `onlyOwner` | Proposes a new owner; reverts if `newOwner` is zero address |
| `acceptOwnership()` | `public` | Called by the pending owner to complete the transfer |
| `renounceOwnership()` | `onlyOwner` | Removes the current owner, making the contract ownerless |

**Two-Step Transfer Flow**

```
Current Owner                     Pending Owner
     │                                  │
     │  transferOwnership(newOwner)     │
     │────────────────────────────────► │  OwnershipTransferStarted
     │                                  │
     │  acceptOwnership()               │
     │◄──────────────────────────────── │  OwnershipTransferred
     │                                  │
```

---

### `StudentRegistry` (`contracts/StudentRegistration.sol`)

Inherits from `Ownable`. Allows the contract owner to register and remove students in an on-chain registry. Each student record stores a name and a student ID. Anyone can query whether an address is registered and retrieve student details.

**Student Struct**
| Field | Type | Description |
|---|---|---|
| `exists` | `bool` | Whether the student record exists |
| `name` | `string` | Student's name |
| `studentId` | `uint256` | Student's ID |

**State Variables**
| Variable | Visibility | Description |
|---|---|---|
| `_registeredStudents` | `private` mapping | Tracks whether each address is registered |
| `_students` | `private` mapping | Maps address to `Student` struct |

**Events**
| Event | Description |
|---|---|
| `StudentRegistered(address indexed student, string name, uint256 studentId)` | Emitted when a student is registered |
| `StudentRemoved(address indexed student)` | Emitted when a student is removed |

**Custom Errors**
| Error | Description |
|---|---|
| `StudentRegistry__CallerIsNotOwner()` | Caller is not the contract owner |
| `StudentRegistry__StudentCannotBeBurnAddress()` | Provided address is the zero address |
| `StudentRegistry__StudentAlreadyRegistered()` | Student is already in the registry |
| `StudentRegistry__StudentNotRegistered()` | Student is not in the registry |

**Functions**
| Function | Visibility | Description |
|---|---|---|
| `registerStudent(address _student, string _name, uint256 _studentId)` | `public` | Registers a new student with name and ID; reverts if zero address or already registered |
| `removeStudent(address _student)` | `onlyOwner` | Removes a student from the registry; reverts if not registered |
| `isRegistered(address _student)` | `view` | Returns `true` if the address is registered |
| `getStudent(address _student)` | `view` | Returns `(exists, name, studentId)` for the given address |

> **Note:** `registerStudent` does **not** have the `onlyOwner` modifier applied, meaning any caller can register a student. `removeStudent` is restricted to the owner via `onlyOwner`. Consider adding `onlyOwner` to `registerStudent` if registration should be admin-only.

## Getting Started

### Prerequisites
- [Remix IDE](https://remix.ethereum.org/) (no local setup required) or a local toolchain like [Foundry](https://book.getfoundry.sh/) / [Hardhat](https://hardhat.org/)

### Compile
1. Open the project in Remix IDE.
2. In the **Solidity Compiler** plugin, select compiler version `0.8.34` (or compatible with `^0.8.20`).
3. Click **Compile StudentRegistration.sol** — this will also compile the imported `Ownable.sol`.

### Deploy
1. Navigate to the **Deploy & Run Transactions** plugin.
2. Select your desired environment (Remix VM, Injected Provider for MetaMask, etc.).
3. Select the `StudentRegistry` contract from the dropdown.
4. Click **Deploy** — no constructor arguments are required.

### Interact
- **Register a student**: Call `registerStudent(address, string, uint256)` with the student's wallet address, name, and ID.
- **Remove a student**: Call `removeStudent(address)` with a registered student's address (owner only).
- **Check registration**: Call `isRegistered(address)` to verify if an address is in the registry.
- **Get student details**: Call `getStudent(address)` to retrieve `(exists, name, studentId)`.
- **Transfer ownership**: Call `transferOwnership(address)` to propose a new owner, then have the new owner call `acceptOwnership()`.
- **Renounce ownership**: Call `renounceOwnership()` to make the contract ownerless (owner only).

## Project Structure

```
.
├── contracts/
│   ├── Ownable.sol                       # Two-step ownership contract
│   └── StudentRegistration.sol           # Student registry (inherits Ownable)
├── artifacts/
│   ├── Ownable.json                      # Compilation artifacts
│   ├── Ownable_metadata.json
│   ├── StudentRegistry.json
│   └── StudentRegistry_metadata.json
├── remix.config.json                     # Remix IDE workspace configuration
└── README.md
```

## Security Considerations

- **Two-step ownership transfer**: Prevents accidental loss of ownership by requiring the new owner to explicitly accept.
- **Zero-address checks**: Both `Ownable` and `StudentRegistry` reject the zero address in relevant functions.
- **Owner privileges**: The owner has full control over student removal. Consider using a multi-sig or governance contract as the owner for production deployments.
- **Open registration**: `registerStudent` is callable by anyone. Add the `onlyOwner` modifier if registration should be restricted to the contract owner.
- **Renouncing ownership**: Calling `renounceOwnership()` is irreversible; ensure no further management is needed before doing so.
- **Gas costs**: Storing `string` names on-chain is gas-intensive. For production, consider storing a hash of the name or using off-chain storage for metadata.

## License

This project is licensed under the **MIT License** (SPDX-License-Identifier: MIT).

## Resources

- [Remix IDE Documentation](https://remix-ide.readthedocs.io/)
- [Solidity Language Documentation](https://docs.soliditylang.org/)
- [OpenZeppelin Ownable (reference implementation)](https://docs.openzeppelin.com/contracts/5.x/access-control)
- [Remix IDE Community Forum](https://forum.remix.ethereum.org/)
