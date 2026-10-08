// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "contracts/Ownable.sol";

contract StudentRegistry is Ownable {
    // Errors
    error StudentRegistry__CallerIsNotOwner();
    error StudentRegistry__StudentCannotBeBurnAddress();
    error StudentRegistry__StudentAlreadyRegistered();
    error StudentRegistry__StudentNotRegistered();

    // Events
    event StudentRegistered(
        address indexed student,
        string name,
        uint256 studentId
    );
    event StudentRemoved(address indexed student);

    // Student identity struct
    struct Student {
        bool exists;
        string name;
        uint256 studentId;
    }
    // Mapping to track registered students
    mapping(address => bool) private _registeredStudents;
    mapping(address => Student) private _students;

    // Register a student (only owner can call)
    function registerStudent(
        address _student,
        string memory _name,
        uint256 _studentId
    ) public {
        if (_student == address(0))
            revert StudentRegistry__StudentCannotBeBurnAddress();
        if (_registeredStudents[_student])
            revert StudentRegistry__StudentAlreadyRegistered();

        _registeredStudents[_student] = true;
        _students[_student] = Student({
            exists: true,
            name: _name,
            studentId: _studentId
        });

        emit StudentRegistered(_student, _name, _studentId);
    }

    // Remove a student (only owner can call)
    function removeStudent(address _student) public onlyOwner {
        if (!_registeredStudents[_student])
            revert StudentRegistry__StudentNotRegistered();

        _registeredStudents[_student] = false;
        delete _students[_student];

        emit StudentRemoved(_student);
    }

    // Check if a student is registered
    function isRegistered(address _student) public view returns (bool) {
        return _registeredStudents[_student];
    }

    // Get student details
    function getStudent(
        address _student
    ) public view returns (bool exists, string memory name, uint256 studentId) {
        Student memory student = _students[_student];
        return (student.exists, student.name, student.studentId);
    }
}
