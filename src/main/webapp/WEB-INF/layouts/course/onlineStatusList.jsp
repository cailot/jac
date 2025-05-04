<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.StudentDTO"%>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils"%>
<%@page import="java.util.Calendar"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
 
  
<script>
// var academicYear;
// var academicWeek;

$(document).ready(function () {

	// make an AJAX call on page load to get the academic year and week
	// $.ajax({
	// 		url : '${pageContext.request.contextPath}/class/academy',
	// 		method: "GET",
	// 		success: function(response) {
	// 			// save the response into the variable
	// 			academicYear = response[0];
	// 			academicWeek = response[1];
	// 			// console.log(response[0]+ ' : ' + response[1]);
	// 		},
	// 		error: function(jqXHR, textStatus, errorThrown) {
	// 			console.log('Error : ' + errorThrown);
	// 		}
	// });

    $('#studyListTable').DataTable({
    	language: {
    		search: 'Filter:'
    	},
    	dom: 'Blfrtip',	
    	buttons: [
    		 'excelHtml5', 
             {
 	            extend: 'pdfHtml5',
 	            download: 'open',
 	            pageSize: 'A0'
 	        },
 	        'print'
        ],
    });
    
	// initialise state list when loading
	listState('#listState');
	listBranch('#listBranch');
	listGrade('#listGrade');

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		// avoid execute several times
		//var hiddenInput = false;
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#listBranch").val(window.branch);
				// Disable #listBranch and #addBranch
				$("#listBranch").prop('disabled', true);
			}
		});
	}

	// send diabled select value via <form>
    document.getElementById("studyList").addEventListener("submit", function() {
        document.getElementById("listState").disabled = false;
		document.getElementById("listBranch").disabled = false;
    });

	// set current year & week
	$.ajax({
		url : '${pageContext.request.contextPath}/class/academy',
		method: "GET",
		success: function(response) {
			// save the response into the variable
			const academicYear = response[0];
			const academicWeek = response[1];
			// console.log('Academic Year : ' + academicYear);
			// console.log('Academic Week : ' + academicWeek);
			$("#listYear").val(academicYear);
			$("#listSet").val(academicWeek);

		},
		error: function(jqXHR, textStatus, errorThrown) {
			console.log('Error : ' + errorThrown);
		}
	});


});
////////////////////////////////////////////////////////////////////////////////////////////////////
//		Link To Student Admin
////////////////////////////////////////////////////////////////////////////////////////////////////
function linkToStudent(studentId) {
	var url = '/studentAdmin?id=' + studentId;  
	var win = window.open(url, '_blank');
	win.focus();
}

</script>

<style>
	div.dataTables_length{
		padding-left: 50px;
		padding-top: 40px;
		padding-bottom: 10px;
	}

	div.dt-buttons {
		padding-top: 35px;
		padding-bottom: 10px;
	}

	div.dataTables_filter {
		padding-top: 35px;
		padding-bottom: 35px;
	}

	#studyListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}  

</style>


<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="studyList" method="get" action="${pageContext.request.contextPath}/loginCheck/onlineAttend">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listState" class="label-form">State</label> 
						<select class="form-control" id="listState" name="listState" disabled>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listBranch" class="label-form">Branch</label> 
						<select class="form-control" id="listBranch" name="listBranch">
							<option value="0">All Branch</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label> 
						<select class="form-control" id="listGrade" name="listGrade">
							<!-- <option value="0">All</option> -->
						</select>
					</div>

					<div class="col-md-2">
						<label for="listYear" class="label-form">Academic Year</label>
						<select class="form-control" id="listYear" name="listYear">
							<%
								Calendar now = Calendar.getInstance();
								int currentYear = now.get(Calendar.YEAR);
								int nextYear = currentYear + 1;
							%>
							<option value="<%= currentYear %>">Academic Year <%= (currentYear%100) %>/<%= (currentYear%100)+1 %></option>
							<%
								// Adding the last five years
								for (int i = currentYear - 1; i >= currentYear - 5; i--) {
							%>
								<option value="<%= i %>">Academic Year <%= (i%100) %>/<%= (i%100)+1 %></option>
							<%
							}
							%>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listSet" class="label-form">Set</label>
						<select class="form-control" id="listSet" name="listSet">
						</select>
						<script>
							// Get a reference to the select element
							var selectElement = document.getElementById("listSet");
							// Loop to add options from 1 to 50
							for (var i = 1; i <= 50; i++) {
								// Create a new option element
								var option = document.createElement("option");
								// Set the value and text content for the option
								option.value = i;
								option.textContent = i;
								// Append the option to the select element
								selectElement.appendChild(option);
							}
						</script>
					</div>
					<div class="offset-md-3"></div>
					<div class="col mx-auto">
						<label for="listState" class="label-form text-white">0</label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>					
				</div>
			</div>
			<!-- Search Info-->
			<c:if test="${branchInfo != null}">
				<div id="searchInfo" class="alert alert-info jae-border-info py-3 mt-4">
					<table style="width: 100%;">
						<colgroup>
							<col style="width: 25%;" />
							<col style="width: 25%;" />
							<col style="width: 25%;" />
							<col style="width: 25%;" />
						</colgroup>
						<tr>
							<td class="text-center">Branch : <span class="font-weight-bold">
								<script type="text/javascript">
									document.write(branchName('${branchInfo}'));
								</script>
							</span></td>
							<td class="text-center">Grade : 
								<span class="font-weight-bold">
									<script type="text/javascript">
										document.write(gradeName('${gradeInfo}'));
									</script>
								</span>
							</td>
							<td class="text-center">Year : <span class="font-weight-bold">								
								<c:choose>
									<c:when test="${yearInfo != null}">
										<c:set var="nextYear" value="${yearInfo + 1}" />
										<c:set var="yearDisplay" value="Academic Year ${fn:substring(yearInfo, 2, 4)}/${fn:substring(nextYear, 2, 4)}" />
										<c:out value="${yearDisplay}" />
									</c:when>
									<c:otherwise>
										<c:out value="Year not available" />
									</c:otherwise>
								</c:choose>
							</span></td>
							<td class="text-center">Set : <span class="font-weight-bold">
								<c:out value="${setInfo}" />
							</span></td>
						</tr>
					</table>						
				</div>
			</c:if>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="studyListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 10%;">Student ID</th>
										<th class="align-middle text-center" style="width: 10%;">First Name</th>
										<th class="align-middle text-center" style="width: 10%;">Last Name</th>
										<th class="align-middle text-center" style="width: 5%;">Grade</th>
										<th class="align-middle text-center" style="width: 15%;">Main Contact</th>
										<th class="align-middle text-center" style="width: 15%;">Main Email</th>								
										<th class="align-middle text-center" style="width: 10%;">Title</th>
										<th class="align-middle text-center" style="width: 5%;">Set</th>
										<th class="align-middle text-center" style="width: 5%;">Status</th>
										<th class="align-middle text-center" style="width: 5%;">Date</th>
									</tr>
								</thead>
								<tbody id="list-student-body">
								<c:choose>
									<c:when test="${LoginList != null}">
										<c:forEach items="${LoginList}" var="login">
											<tr>
												<td class="small align-middle hand-cursor" data-toggle="tooltip" title="Link to Student Information" id="studentId" name="studentId" onclick="linkToStudent('${login.studentId}')">
													<span class="ml-1"><c:out value="${login.studentId}" /></span>
												</td>												
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.firstName}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.lastName}" /></span></td>
												<td class="small align-middle text-center">
													<span>
														<c:choose>
															<c:when test="${login.grade == '1'}">P2</c:when>
															<c:when test="${login.grade == '2'}">P3</c:when>
															<c:when test="${login.grade == '3'}">P4</c:when>
															<c:when test="${login.grade == '4'}">P5</c:when>
															<c:when test="${login.grade == '5'}">P6</c:when>
															<c:when test="${login.grade == '6'}">S7</c:when>
															<c:when test="${login.grade == '7'}">S8</c:when>
															<c:when test="${login.grade == '8'}">S9</c:when>
															<c:when test="${login.grade == '9'}">S10</c:when>
															<c:when test="${login.grade == '10'}">S10E</c:when>
															<c:when test="${login.grade == '11'}">TT6</c:when>
															<c:when test="${login.grade == '12'}">TT8</c:when>
															<c:when test="${login.grade == '13'}">TT8E</c:when>
															<c:when test="${login.grade == '14'}">SRW4</c:when>
															<c:when test="${login.grade == '15'}">SRW5</c:when>
															<c:when test="${login.grade == '16'}">SRW6</c:when>
															<c:when test="${login.grade == '17'}">SRW7</c:when>
															<c:when test="${login.grade == '18'}">SRW8</c:when>
															<c:when test="${login.grade == '19'}">JMSS</c:when>
															<c:when test="${login.grade == '20'}">VCE</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.contactNo}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.email}" /></span></td>
												<td class="small align-middle">
													<span>
														<c:out value="${login.onlineName}" />
													</span>
												</td>
												<!-- set -->
												<td class="small align-middle text-center"><span><c:out value="${login.set}" /></span></td>
												<!-- status -->
												<td class="small align-middle text-center">
													<span>
														<c:choose>
															<c:when test="${login.status == 0}"></c:when>
															<c:when test="${login.status == 1}">Proceeding</c:when>
															<c:when test="${login.status == 2}">Completed</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<!-- start date -->
												<td class="small align-middle text-center">
													<span>
														<c:if test="${not empty login.startDateTime}">
															<c:out value="${login.startDateTime}" />
														</c:if>
														<c:if test="${empty login.startDateTime}">
										
														</c:if>
													</span>
												</td>
											</tr>
										</c:forEach>
									</c:when>
								</c:choose>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</form>
	</div>
</div>

