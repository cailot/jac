<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<div class="container-fluid">
  <div class="row">
	<!-- Student Info -->
    <div class="col-lg-4">
    	<div class="card-body">
      		<h5>Student Information</h5>
			<jsp:include page="student/admin/studentInfo.jsp"></jsp:include>
		</div>
    </div>
	<div class="col-lg-8">
      	<div class="row">
			<!-- Course Info -->
			<div class="col-lg-8" style="padding-left: 1px; padding-right: 1px;">
				<div class="card-body" style="padding-left: 1px; padding-right: 1px;">
					<h5>Course Registration</h5>
					<jsp:include page="student/admin/courseInfo.jsp"></jsp:include>
				</div>
			</div>
			<!-- Attendance Info -->
			<div class="col-lg-4 ">
				<div class="card-body">
					<h5 class="card-title">Attendance</h5>
					<jsp:include page="student/admin/attendanceInfo.jsp"></jsp:include>
				</div>
			</div>
		</div>
      	<div class="row">
			<!-- Invoice Info-->
      		<div class="col-lg-12">
      			<div class="card-body">
					<jsp:include page="student/admin/invoiceInfo.jsp"></jsp:include>
      			</div>
      		</div>
      	</div>     		
    	</div>
    </div>
 </div>

 


