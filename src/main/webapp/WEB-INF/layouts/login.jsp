<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script>

$(function() {
    
	// Initially hide the resetCard
    $('#resetCard').hide();

    // Show resetCard and hide loginCard when 'Forgot your password?' is clicked
    $('#showResetFromLogin').click(function(e) {
        e.preventDefault();
        $('#loginCard').hide();
        $('#resetCard').show();
    });

    // Show loginCard and hide resetCard when 'Remembered your password?' is clicked
    $('#showLoginFromReset').click(function(e) {
        e.preventDefault();
        $('#resetCard').hide();
        $('#loginCard').show();
    });


});

//////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Reset Password
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
function resetPassword(){
	var userId = $('#resetRequest input[name="userId"]').val();
	var email = $('#resetRequest input[name="email"]').val();
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/user/requestReset/',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify({username : userId, email : email}),
		contentType : 'application/json',
		success : function(value) {
			$('#success-alert .modal-body').html(value);
			$('#success-alert').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
			$('#error-alert .modal-body').html(value);
			$('#error-alert').modal('toggle');
		}
	});
}

</script>

<style>

#background {
  width: 100%;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: rgba(0, 0, 0, 0.5);
  overflow: hidden;
  position: relative;
}

.background-animation {
  width: 100%;
  height: 100vh;
  background-image: url('${pageContext.request.contextPath}/image/login.png');
  background-size: cover;
}

.left-container {
	position: absolute;
	left: 0;
	width: 35%;
	height: 100vh;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
}

.card-container {
	width: 100%;
	display: flex;
	justify-content: center;
	align-items: center;
}
</style>
<div id="background" class="col-md-12" style="padding-left: 0px; padding-right: 0px;">
	<div class="background-animation">
		<div class="left-container">
			<h3 class="text-white text-center" ><img src="${pageContext.request.contextPath}/image/logo.png"></img></h3>
			<div id="loginCard">
				<h6 class="text-secondary text-center mb-4" style="background: #ffffff !important;">Sign In To James An College</h6>
				<div class="card-container">			
					<div class="row h-100 justify-content-center align-items-center">						
						<div class="card">
							<h3 class="card-header text-white text-center" style="background: #2d398e !important;">Jac Manager</h3>
							<div class="card-body">
								<form:form  action="${pageContext.request.contextPath}/processLogin" method="POST">
									<div class="row mb-1">
										<div class="col-md-12">
											<div class="form-group">
												<!-- Check for login error -->
												<c:if test="${param.error != null}">
													<div class="alert alert-danger col-xs-offset-1 col-xs-10">
													Invalid username and password.
													</div>
												</c:if>
												<!-- Check for logout -->
												<c:if test="${param.logout != null}">
													<div class="alert alert-success col-xs-offset-1 col-xs-10">
													You have been logged out.
													</div>
												</c:if>
												<label>Username</label>
												<div class="input-group">
													<div class="input-group-prepend">
													<span class="input-group-text text-white" style="background: #2d398e !important;"><i class="bi bi-person-fill text-white" aria-hidden="true"></i></span>
													</div>
													<input type="text" class="form-control" name="username" placeholder="Enter your ID" />
												</div>
												<div class="help-block with-errors text-danger">
												</div>
											</div>
										</div>
									</div>
									<div class="row mb-3">
										<div class="col-md-12">
											<div class="form-group">
												<label>Password</label>
												<div class="input-group">
													<div class="input-group-prepend">
													<span class="input-group-text text-white" style="background: #2d398e !important;"><i class="bi bi-unlock-fill text-white" aria-hidden="true"></i></span>
													</div>
													<input type="password" name="password" class="form-control" placeholder="Enter your password"/>
												</div>
												<div class="help-block with-errors text-danger"></div>
											</div>
										</div>
									</div>
									<div class="row mb-3">
										<div class="col-md-12">
											<input type="hidden" name="redirect" value="">
											<input type="submit" class="btn btn-lg btn-block text-white" style="background: #2d398e !important;" value="Login" name="submit">
										</div>
									</div>
									<div class="row">
										<div class="col-md-12">
											<div class="text-primary text-right small">
												<a href="#" id="showResetFromLogin" class="text-primary text-right small">
													Forgot your password?
												</a>	
											</div>
										</div>
									</div>
								</form:form>
							</div>
						</div>		
					</div>
				</div> <!-- end of card-container -->
			</div><!-- end of login section -->
			
			
			
			
			
			
			
			
			
			
			
			<div id="resetCard">
				<h6 class="text-secondary text-center mb-4" style="background: #ffffff !important;">Enter Your Info To Reset Password</h6>
				<div class="card-container">			
					<div class="row h-100 justify-content-center align-items-center">						
						<div class="card">
							<h3 class="card-header text-white text-center" style="background: #2d398e !important;">Reset Password</h3>
							<div class="card-body">
								<form id="resetRequest">
									<div class="row mb-1">
										<div class="col-md-12">
											<div class="form-group">
												<label>Username</label>
												<div class="input-group">
													<div class="input-group-prepend">
													<span class="input-group-text text-white" style="background: #2d398e !important;"><i class="bi bi-person-fill text-white" aria-hidden="true"></i></span>
													</div>
													<input type="text" class="form-control" name="userId" placeholder="Enter your ID" />
												</div>
											</div>
										</div>
									</div>
									<div class="row mb-3">
										<div class="col-md-12">
											<div class="form-group">
												<label>Email</label>
												<div class="input-group">
													<div class="input-group-prepend">
													<span class="input-group-text text-white" style="background: #2d398e !important;"><i class="bi bi-envelope-fill text-white" aria-hidden="true"></i></span>
													</div>
													<input type="text" name="email" class="form-control" placeholder="Enter your email"/>
												</div>
											</div>
										</div>
									</div>
									<div class="row mb-3">
										<div class="col-md-12">
											<button type="submit" class="btn btn-lg btn-block text-white" style="background: #2d398e !important;" onclick="resetPassword()">Request</button>
										</div>
									</div>
									<div class="row">
										<div class="col-md-12">
											<div class="text-primary text-right small">
												<a href="#" id="showLoginFromReset" class="text-primary text-right small">
													Remembered your password?
												</a>	
											</div>
										</div>
									</div>
								</form>
							</div>
						</div>		
					</div>
				</div> <!-- end of reset card-container -->
			</div> <!-- end of reset section -->
			
			
			
			
			
			
			<h6 class="text-center" style="position: fixed; bottom: 0; width: 100%;">
				2015 - <%=new java.util.Date().getYear() + 1900%>&copy;&nbsp; All rights reserved.&nbsp;&nbsp;
				<div class="copyright-font-color">James An College</div>
			</h6>		
		</div><!-- end of left-container-->
	</div>
</div>


<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
			<i class="fa fa-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Error Alert -->
<div id="error-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-danger alert-dialog-display jae-border-danger">
			<i class="fa fa-exclamation-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>
