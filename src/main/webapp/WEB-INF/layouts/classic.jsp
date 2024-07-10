<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<html>
<head>
<title><tiles:getAsString name="title" /></title>
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
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-icons.min.css"/>
<!-- Google Icons -->
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">

<style>
    .session-timeout-bar {
        position: fixed;
        top: 0;
        width: 100%;
        z-index: 1050;
        display: none;
    }
    .main-content {
        transition: padding-top 0.3s; /* Smooth transition for padding */
    }
</style>
<script>
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
            <div class="row" style="padding: 15px 20px;">
                2015 - <%=new java.util.Date().getYear() + 1900%>&copy;&nbsp; All rights reserved.&nbsp;&nbsp;
                <div class="copyright-font-color">James An College <span class="small text-secondary">v0.1.3</span></div>
            </div>
        </footer>	
    </div>

    <!-- Success Alert -->
    <div id="success-alert" class="modal fade">
        <div class="modal-dialog">
            <div class="alert alert-block alert-success alert-dialog-display">
                <i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
                <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            </div>
        </div>
    </div>

    <!-- Warning Alert -->
    <div id="warning-alert" class="modal fade">
        <div class="modal-dialog">
            <div class="alert alert-block alert-warning alert-dialog-display">
                <i class="bi bi-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
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
            <div class="alert alert-block alert-danger alert-dialog-display">
                <i class="bi bi-exclamation-circle h5 mt-2"></i>&nbsp;&nbsp;<div class="modal-body"></div>
                <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
            </div>
        </div>
    </div>
</body>
</html>