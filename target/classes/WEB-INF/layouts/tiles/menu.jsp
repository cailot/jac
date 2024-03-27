<%@taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<div class="container-fluid jae-header">
<nav class="navbar">
	<div class="navbar_logo">
		<img src="${pageContext.request.contextPath}/image/logo.png" style="filter: brightness(0) invert(1);width:45px;" >
		James An College
	</div>
	<ul class="navbar_menu">
		<!-- Student -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons mr-2 custom-icon">school</span><span class="h5">Student</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentAdmin">Administration</a>
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/studentList">Enrolment List</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentInvoice">Invoice Record</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentAttendance">Attendance</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentGrade">Grade Update</a>
			</div>
		</li>
		<!-- Teacher -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons mr-2 custom-icon">face</span><span class="h5">Teacher</span>
			</a>
			<div class="dropdown-menu">
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/teacherList">Teacher List</a>
			</div>
		</li>
		<!-- Class -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons mr-2 custom-icon">menu_book</span><span class="h5">Class Management</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/courseList">Course List</a>
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/classList">Class List</a>
				<!-- <a class="dropdown-item" href="${pageContext.request.contextPath}/gradeList">Grade List</a> -->
			</div>
		</li>
		<!-- Jac Study -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons mr-2 custom-icon">cast_for_education</span><span class="h5">JAC Study</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/onlineList">Online Class</a>				
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/homeworkList">Homework</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/extraworkList">Extra Materials</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/practiceList">Practice</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/testList">Test</a>
			</div>
		</li>
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons mr-2 custom-icon">settings</span><span class="h5">Setting</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/cycle">Academic Cycle</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/branch">Branch Management</a>
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/setting">Admin Automation</a>
				<a class="dropdown-item" href="#">Admin Property</a>
			</div>
		</li>
	</ul>
	<ul class="navbar_icon" style="margin: 0; padding: 0;">
		<sec:authorize access="isAuthenticated()">
			<div class="card-body jae-background-color text-right" style="display: flex; justify-content: space-between; padding-top: 20px;">
				<div>
					<span class="card-text text-warning font-weight-bold font-italic h6" style="margin-left: 5px; cursor: pointer;" id="studentName" onclick="clearPassword();retrieveStudentInfo()">Jinhyung Seo</span>
					<span class="h6" style="color: white; align-items: center; justify-content: center;">&nbsp;(Administrator)</span>
				</div>
				<form:form action="${pageContext.request.contextPath}/staff/logout" method="POST" id="logout" style="margin-bottom: 0px;">
					<button class="btn mr-1"><i class="bi bi-box-arrow-right custom-icon text-warning" title="Log Out"></i></button>
				</form:form>
			</div>
		</sec:authorize> 
	</ul>
</nav>
</div>
 