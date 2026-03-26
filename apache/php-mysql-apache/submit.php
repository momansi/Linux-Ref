<?php
// Database connection
$servername = "192.168.1.10"; // or your server IP
$username = "iti";         // MySQL user
$password = "P@sword2001";    // MySQL password
$dbname = "iti";           // Database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get POST data
$firstname = $_POST['firstname'];
$lastname  = $_POST['lastname'];
$email     = $_POST['email'];

// Prepare SQL statement
$sql = "INSERT INTO userinfo (firstname, lastname, email) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $firstname, $lastname, $email);

// Execute and check
if ($stmt->execute()) {
    echo "Application submitted successfully!";
} else {
    echo "Error: " . $stmt->error;
}

// Close connections
$stmt->close();
$conn->close();
?>
