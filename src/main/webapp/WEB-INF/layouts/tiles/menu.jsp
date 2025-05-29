<%@taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="container-fluid jae-header">
<c:set var="isAdmin" value="${false}" />
<c:set var="role" value="" />
<c:set var="firstName" value="" />
<c:set var="lastName" value="" />

<sec:authorize access="isAuthenticated()">
<sec:authentication var="role" property='principal.authorities'/>
<sec:authentication var="id" property="principal.username"/>
<sec:authentication var="firstName" property="principal.firstName"/>
<sec:authentication var="lastName" property="principal.lastName"/>
<sec:authentication var="state" property="principal.state"/>
<sec:authentication var="branch" property="principal.branch"/>
	<c:if test="${role == '[Administrator]'}" >
		<c:set var="isAdmin" value="${true}" />
	</c:if>
	<c:set var="role" value="${role}" />
	<c:set var="firstName" value="${firstName}" />
	<c:set var="lastName" value="${lastName}" />
	<!-- Save global variables -->
	<script>
		window.isAdmin = "${isAdmin}";
		window.username = "${id}";
		window.state = "${state}";
		window.branch = "${branch}";
		// Check if window.isAdmin is "true"
		if (window.isAdmin === "true") {
			// Set window.state and window.branch to "0"
			window.state = "0";
			window.branch = "0";
		}
	</script>

</sec:authorize>

<nav class="navbar mt-2 mb-2">
	<div class="navbar_logo">
		<a href="${pageContext.request.contextPath}/studentAdmin">
			<img src="${pageContext.request.contextPath}/image/logo-manager.png" style="filter: brightness(0) invert(1);width:55px;" />
		</a>	
		<span class="ml-3 h3">James An College</span>
	</div>
	<ul class="navbar_menu">
		<!-- Student -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">Student</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentAdmin">Administration</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentInvoice">Invoice Record</a>
				<!-- Student List submenu -->
				<div class="dropdown-submenu">
					<a class="dropdown-item" href="#" id="testDropdown" role="button" aria-haspopup="true" aria-expanded="false">
						Student List
					</a>
					<div class="dropdown-menu" aria-labelledby="studentListDropdown">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/studentBranchList">Overview</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/studentEnrol">Enrolment</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/paymentList">Payment</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/overdueList">Overdue</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/renewList">Renewal</a>
					</div>
				</div>
			</div>
		</li>
		<!-- Class -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">
					<c:if test="${isAdmin}">
						Lecture
					</c:if>
					<c:if test="${!isAdmin}">
						Class
					</c:if>
				</span>
			</a>
			<div class="dropdown-menu">
				<c:if test="${isAdmin}">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/courseList">Course Management</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/bookList">Book Management</a>
				</c:if>
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/classList">Class Management</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/studentAttendance">Attendance</a>
				<!-- Jac Study submenu -->
				<div class="dropdown-submenu">
					<a class="dropdown-item" href="#" id="testDropdown" role="button" aria-haspopup="true" aria-expanded="false">
						JAC Study Check
					</a>
					<div class="dropdown-menu" aria-labelledby="Practice">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/onlineStatus">Online Class</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/connectedAttend">Connected Class</a>
					</div>
				</div>
				<!-- OMR -->
				<!-- <a class="dropdown-item" href="${pageContext.request.contextPath}/omrUpload">OMR Upload</a> -->
			</div>
		</li>
		<!-- User -->
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">User</span>
			</a>
			<div class="dropdown-menu">
			  	<a class="dropdown-item" href="${pageContext.request.contextPath}/userList">
					<c:if test="${isAdmin}">
						User Management
					</c:if>
					<c:if test="${!isAdmin}">
						Staff Management
					</c:if>
				</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/teacherList">Teacher Management</a>
			</div>
		</li>
		<!-- Jac Study -->
		<c:if test="${isAdmin}">
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">JAC Study</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/onlineList">Online Class</a>
				<!-- Homework submenu -->
				<div class="dropdown-submenu">
					<a class="dropdown-item" href="#" id="homeworkDropdown" role="button" aria-haspopup="true" aria-expanded="false">
						Homework
					</a>
					<div class="dropdown-menu" aria-labelledby="homeworkDropdown">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/homeworkList">List</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/homeworkSchedule">Schedule</a>
					</div>
				</div>
				
				<a class="dropdown-item" href="${pageContext.request.contextPath}/extraworkList">Extra Materials</a>
				<!-- Practice submenu -->
				<div class="dropdown-submenu">
					<a class="dropdown-item" href="#" id="practiceDropdown" role="button" aria-haspopup="true" aria-expanded="false">
						Practice
					</a>
					<div class="dropdown-menu" aria-labelledby="practiceDropdown">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/practiceList">List</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/practiceSchedule">Schedule</a>
					</div>
				</div>
				<!-- Class Test submenu -->
				<div class="dropdown-submenu">
					<a class="dropdown-item" href="#" id="testDropdown" role="button" aria-haspopup="true" aria-expanded="false">
						Class Test
					</a>
					<div class="dropdown-menu" aria-labelledby="Practice">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/testList">List</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/testSchedule">Schedule</a>
					</div>
				</div>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/assessList">Assessment</a>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/omrUpload">OMR Upload</a>

			</div>
		</li>
		</c:if>
		<li class="nav-item dropdown">
			<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
				<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">Setting</span>
			</a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="${pageContext.request.contextPath}/branchManage">Branch Management</a>
				<c:choose>
					<c:when test="${isAdmin}">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/cycle">Academic Cycle</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/batch">Batch Process</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/studentGrade">Grade Update</a>
						<!-- Migration submenu -->
						<div class="dropdown-submenu">
							<a class="dropdown-item" href="#" id="migrationDropdown" role="button" aria-haspopup="true" aria-expanded="false">
								Student Migration
							</a>
							<div class="dropdown-menu" aria-labelledby="migrationDropdown">
								<a class="dropdown-item" href="${pageContext.request.contextPath}/migrationStudent">1. Student</a>
								<!-- <a class="dropdown-item" href="${pageContext.request.contextPath}/migrationInvoice">Invoice</a> -->
								<a class="dropdown-item" href="${pageContext.request.contextPath}/migrationEnrol">2. Enrolment</a>
								<a class="dropdown-item" href="${pageContext.request.contextPath}/migrationMaterial">3. Material</a>
								<a class="dropdown-item" href="${pageContext.request.contextPath}/migrationEtc">4. Etc</a>
								<a class="dropdown-item" href="${pageContext.request.contextPath}/migrationPayment">5. Payment</a>
	
							</div>
						</div>
					</c:when>
					<c:otherwise>
						<!-- Content for branch -->
						<a class="dropdown-item" href="${pageContext.request.contextPath}/branchStats">Branch Statistics</a>
					</c:otherwise>
				</c:choose>
				<a class="dropdown-item" href="${pageContext.request.contextPath}/branchEmail">Email Announcement</a>								

			</div>
		</li>
		<c:choose>
			<c:when test="${isAdmin}">
				<li class="nav-item dropdown">
					<a class="nav-link" href="" role="button" aria-haspopup="true" aria-expanded="false">
						<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">Stats</span>
					</a>
					<div class="dropdown-menu">
						<a class="dropdown-item" href="${pageContext.request.contextPath}/activeStats">Active Student</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/inactiveStats">Inactive Student</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/invoiceStats">Payment Student</a>
						<a class="dropdown-item" href="${pageContext.request.contextPath}/omrStats">OMR Statistics</a>
					</div>
				</li>
			</c:when>
			<c:otherwise><!-- branch -->
				<li class="nav-item dropdown">
					<a class="nav-link" href="${pageContext.request.contextPath}/pdf/guide.pdf" download>
						<span class="material-icons custom-icon mr-2">manage_accounts</span><span class="h5">Document</span>
					</a>
				</li>
			</c:otherwise>
		</c:choose>		
	</ul>
	<ul class="navbar_icon" style="margin: 0; padding: 0;">
		<sec:authorize access="isAuthenticated()">
		<div class="card-body jae-background-color text-right" style="display: flex; justify-content: space-between; align-items: center; padding-top: 20px;">
			<div style="display: flex; align-items: center; margin-top: 5px;">
				<table>
					<tr>
						<td><span class="card-text text-warning font-weight-bold font-italic h6" style="margin-left: 5px;"><c:out value="${firstName}"/> <c:out value="${lastName}"/></span></td>
						<td><span class="h6" style="color: white;">&nbsp;<c:out value="${role}"/></span></td>
					</tr>
					<tr>
						<td colspan="2" class="text-center"><span class="small" style="color: white;">
							<c:set var="now" value="<%= new java.util.Date() %>" />
							Logged at <fmt:formatDate value="${now}" pattern="dd/MM/yyyy HH:mm" />
						</span>
						</td>
					</tr>
				</table>
			</div>
			<form:form action="${pageContext.request.contextPath}/logout" method="POST" id="logout" style="margin-bottom: 0px;">
				<button class="btn mr-1"><i class="bi bi-power custom-icon text-warning" title="Log Out"></i></button>
			</form:form>
		</div>
		</sec:authorize> 
	</ul>
</nav>
</div>
 
<style>
	/* Main menu (top-level) */
	ul.navbar_menu > li.nav-item > a.nav-link:hover,
	ul.navbar_menu > li.nav-item > a.nav-link:focus,
	ul.navbar_menu > li.nav-item > a.nav-link:hover .material-icons,
	ul.navbar_menu > li.nav-item > a.nav-link:focus .material-icons {
		color: #ffC107 !important;
		background-color: inherit !important;
	}
	/* Submenu (dropdown) */
	ul.navbar_menu li.nav-item.dropdown .dropdown-menu a.dropdown-item:hover,
	ul.navbar_menu li.nav-item.dropdown .dropdown-menu a.dropdown-item:focus,
	ul.navbar_menu li.nav-item.dropdown .dropdown-menu a.dropdown-item:hover .material-icons,
	ul.navbar_menu li.nav-item.dropdown .dropdown-menu a.dropdown-item:focus .material-icons {
		color: #ffC107 !important;
		background-color: #2d398e !important;
	}
</style>
 