<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<html>
<head>
<title><tiles:getAsString name="title" /></title>
<!-- Favicon -->
<link rel="icon" href="${pageContext.request.contextPath}/image/favicon.ico" type="image/x-icon">

<link href="${pageContext.request.contextPath}/css/jae.css" rel="stylesheet" type="text/css"/>

<!-- Bootstrap CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-4.3.1.min.css"/>	
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery-ui-1.12.1.css"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery-ui.theme.min.css">

<script type="text/javascript" src="${pageContext.request.contextPath}/js/jae.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery-ui-1.13.2.min.js"></script>
<script src="${pageContext.request.contextPath}/js/bootstrap-4.3.1.min.js"></script>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle-4.5.3.min.js"></script>	

<!-- Bootstrap Icons -->
<!-- <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-icons.min.css"/> -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-icons.css"></link>

<!-- Google Icons -->
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">

<style>
    /* Reset body margins and padding */
    body {
        margin: 0;
        padding: 0;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        background-color: #f8f9fa;
    }

    /* Base layout styles */
    .container-fluid {
        width: 100%;
        padding-right: 5px;
        padding-left: 5px;
        margin-right: 0;
        margin-left: 0;
    }

    /* Only constrain width on extra large screens */
    @media (min-width: 1600px) {
        .container-fluid {
            max-width: 1800px;
            margin: 0 auto;
            padding-right: 15px;
            padding-left: 15px;
        }
    }

    @media (min-width: 1920px) {
        .container-fluid {
            max-width: 2000px;
        }
    }

    /* Modal and fieldset headers */
    .fieldset {
        border: 1px solid #dee2e6;
        border-radius: 0.25rem;
        padding: 0.8rem 1rem 1rem;
        margin: 1.5rem 0 1rem;
        position: relative;
    }

    .fieldset header {
        font-size: 1.4rem !important;
        font-weight: 500;
        padding: 0 1rem;
        background-color: #f8f9fa;
        position: absolute;
        top: -1.1rem;
        left: 1rem;
        z-index: 1;
    }

    /* Session timeout bar */
    .session-timeout-bar {
        position: fixed;
        top: 0;
        width: 100%;
        z-index: 1050;
        display: none;
    }

    .main-content {
        transition: padding-top 0.3s;
        flex: 1;
        width: 100%;
    }

    .tooltip {
        z-index: 1050 !important;
    }

    /* Form layout improvements */
    .form-row {
        margin-right: -5px;
        margin-left: -5px;
    }

    .form-row > .col,
    .form-row > [class*="col-"] {
        padding-right: 5px;
        padding-left: 5px;
    }

    /* Table improvements */
    .table-responsive {
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
    }

    /* Header menu styling */
    .row:first-child {
        margin-top: 0;
    }

    /* Footer styling */
    footer {
        background: #fff;
        padding: 15px 0;
        margin-top: auto;
        border-top: 1px solid #dee2e6;
    }

    .footer-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 15px;
    }

    /* Section cards */
    .section-card {
        background: #fff;
        border-radius: 4px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        margin-bottom: 20px;
        padding: 20px;
    }

    /* Form section spacing */
    .form-section {
        margin-bottom: 25px;
    }

    .form-section:last-child {
        margin-bottom: 0;
    }

    /* Label styling */
    .label-form {
        margin-bottom: 0.3rem;
        font-size: 0.9rem;
        color: #495057;
    }

    /* Form groups and sections */
    .form-group {
        margin-bottom: 0.8rem;
    }

    .form-row + .form-row {
        margin-top: 0.8rem;
    }

    /* Modal title styling */
    .modal-title {
        font-size: 1.5rem;
        font-weight: 500;
        color: #2c3e50;
    }

    /* Student Registration specific styling */
    .student-registration-title {
        font-size: 1.5rem;
        font-weight: 500;
        color: #2c3e50;
        margin-bottom: 1.5rem;
        padding: 0.5rem 0;
    }

    /* Modal form spacing */
    .modal-body .form-row:first-child {
        margin-top: 0.3rem;
    }

    .modal-body section.fieldset {
        margin-top: 1.8rem;
    }

    /* Nested fieldset adjustments */
    .fieldset .fieldset {
        margin-top: 1rem;
        margin-bottom: 0.5rem;
    }

    .fieldset .fieldset header {
        font-size: 1rem !important;
        top: -0.8rem;
    }
</style>
<script>
    $(function() {
        // Enable Bootstrap tooltips
        $('[data-toggle="tooltip"]').tooltip();
    });

    var sessionTimeout = 1000*60*30; // 30 mins for demonstration
    var warningTime = 1000*60*25; // Show warning at 25 mins

    var timeoutTimer;
    var warningTimer;
    var inactivityInterval;
    var alertVisible = false;
  
    function showSessionTimeoutBar() {
        var timeoutBar = document.querySelector('.session-timeout-bar');
        timeoutBar.style.display = 'block';
        document.querySelector('.main-content').style.paddingTop = timeoutBar.offsetHeight + 'px';
        alertVisible = true;
    }

    function resetSessionTimeout() {
        clearTimeout(timeoutTimer);
        clearTimeout(warningTimer);

        timeoutTimer = setTimeout(function() {
            // Perform session timeout actions, e.g., log out the user
        }, sessionTimeout);

        if (!alertVisible) {
            warningTimer = setTimeout(showSessionTimeoutBar, warningTime);
        }
    }

    function setupSessionExtension() {
        document.addEventListener('mousemove', resetInactivityInterval);
        document.addEventListener('keypress', resetInactivityInterval);
        document.addEventListener('click', resetInactivityInterval);
        document.addEventListener('scroll', resetInactivityInterval);
    }

    function resetInactivityInterval() {
        clearInterval(inactivityInterval);
        resetSessionTimeout(); // Reset the session timeout timers
        inactivityInterval = setInterval(function() {
            if (!alertVisible) {
                showSessionTimeoutBar();
            }
        }, sessionTimeout); // Restart the inactivity interval
    }

    // Initialize session timeout tracking
    document.addEventListener('DOMContentLoaded', function() {
        setupSessionExtension();
        resetInactivityInterval(); // Initial setup
    });
</script>
</head>
<body>
    <div class="session-timeout-bar alert alert-danger alert-dismissible fade show" role="alert">
		<div style="display: flex; justify-content: space-between; align-items: center;">
			<div>
				<strong>Session Timeout</strong>
				<span class="small ml-3">Your session's been inactive for a while, so we've logged you off from JAC Manager to keep your accounts and details safe.</span>
			</div>
			<a href="/login">Return to the log on page</a>
		</div>
    </div>

    <div class="container-fluid d-flex h-100 flex-column main-content">
        <div class="row">
            <tiles:insertAttribute name="menu" />
        </div>
        <div class="row justify-content-center">
            <tiles:insertAttribute name="body" />

        </div>
        <footer class="mt-auto">
            <div class="row ml-3" style="padding: 15px 20px;">
                2015 - <%=new java.util.Date().getYear() + 1900%>&copy;&nbsp; All rights reserved.&nbsp;&nbsp;
                <div class="copyright-font-color">James An College <span class="small text-secondary">v0.5.6</span></div>
            </div>
        </footer>	
    </div>

    <!-- Success Alert -->
    <div id="success-alert" class="modal fade">
        <div class="modal-dialog">
            <div class="alert alert-block alert-success alert-dialog-display jae-border-success">
                <i class="bi bi-check-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
                <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            </div>
        </div>
    </div>

    <!-- Warning Alert -->
    <div id="warning-alert" class="modal fade">
        <div class="modal-dialog">
            <div class="alert alert-block alert-warning alert-dialog-display jae-border-warning">
                <i class="bi bi-exclamation-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
                <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            </div>
        </div>
    </div>

    <!-- Delete Alert -->
    <div id="confirm-alert" class="modal fade">
        <div class="modal-dialog">
            <div class="alert alert-block alert-danger">
                <div class="alert-dialog-display">
                    <i class="bi bi-minus-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
                </div>
                <div style="text-align: right;">
                    <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-sm btn-danger" id="deactivateAction">Delete</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Validation Alert -->
    <div id="validation-alert" class="modal fade">
        <div class="modal-dialog">
            <div class="alert alert-block alert-danger alert-dialog-display jae-border-danger">
                <i class="bi bi-exclamation-circle-fill h5 mt-2"></i>&nbsp;&nbsp;<div class="modal-body"></div>
                <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            </div>
        </div>
    </div>

<!-- Loading Spinner -->
<div class="modal fade" id="loading-spinner" data-backdrop="static" data-keyboard="false" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered">
		<div class="modal-content loading-spinner-content">
			<div class="modal-body text-center p-5">
				<div class="spinner-border text-primary" role="status" style="width: 4rem; height: 4rem;">
					<span class="sr-only">Loading...</span>
				</div>
				<div id="loading-message" class="mt-4 text-primary h4"></div>
			</div>
		</div>
	</div>
</div>



</body>
</html>