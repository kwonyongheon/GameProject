<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>내 게시물</title>
<style>
html, body 
{
    margin: 0;
    padding: 0;
    overflow: hidden;
    height: 100%;
    width: 100%;
}

body {
    font-family: Arial, sans-serif;
    background-color: #fff; /* Ensure the body background color is white */
    margin: 0;
    padding: 0;
    overflow: hidden; /* Prevent scrolling */    
}

.container {
    background: #ffffff;
    overflow: auto; /* Allow scrolling within the container */
}

.header-container {
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    margin-bottom: 20px;
    padding-top: 20px; /* Add padding at the top */
}

.header-container h2 {
    margin: 0;
}

.divider {
    height: 1px;
    background: #ddd;
    margin: 20px 0;
}

.button-container {
    text-align: center;
    margin: 20px 0;
}

.button-container button {
    width: 120px;
    height: 45px;
    font-size: 16px;
    border: 0;
    outline: none;
    border-radius: 5px;
    background-color: #4CAF50;
    color: white;
    cursor: pointer;
    margin: 0 10px;
    transition: background-color 0.3s, transform 0.3s;
}

.button-container button:hover {
    background-color: #45a049;
    transform: scale(1.05);
}
</style>
</head>
<body>
<div class="container">
    <div class="header-container">
        <h2>내 게시물</h2>
    </div>
    <div class="divider"></div>
    <div class="button-container">
    	<button onclick="location.href='MyProblems.jsp'" target="contentFrame">내 문제</button>
    	<button onclick="location.href='MyPosts.jsp'" target="contentFrame">내 게시물</button>
    </div>
</div>
</body>
</html>
