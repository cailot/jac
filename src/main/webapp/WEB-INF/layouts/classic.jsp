<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<html>
<head>
<title><tiles:getAsString name="title" /></title>
<link href="${pageContext.request.contextPath}/css/jae.css" rel="stylesheet" type="text/css"/>

<!-- Bootstrap CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-4.3.1.min.css"/>	
	
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jae.js"></script>

<!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script> -->
<script src="${pageContext.request.contextPath}/js/jquery-3.6.0.min.js"></script>

<!-- <script src="https://cdn.jsdelivr.net/npm/popper.js@1.14.7/dist/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script> -->
<script src="${pageContext.request.contextPath}/js/popper.min.js"></script>
<!-- <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script> -->
<script src="${pageContext.request.contextPath}/js/bootstrap-4.3.1.min.js"></script>
	
<!-- Link to Bootstrap Datepicker CSS -->
<link rel="stylesheet"	href="${pageContext.request.contextPath}/css/bootstrap-datepicker-1.9.0.min.css">
<!-- Link to Bootstrap Datepicker JavaScript -->
<script	src="${pageContext.request.contextPath}/js/bootstrap-datepicker-1.9.0.min.js"></script>
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-icons.min.css">

</head>
<body>
	<div class="container-fluid d-flex h-100 flex-column">
		<div class="row">
			<tiles:insertAttribute name="menu" />
		</div>
		<div class="row justify-content-center align-items-center">
			<tiles:insertAttribute name="body" />
		</div>
		<footer class="mt-auto">
			<div class="row dhhs-color" style="padding: 15px 20px;">
				2018 -
				<%=new java.util.Date().getYear() + 1900%>
				&copy;&nbsp; All rights reserved.&nbsp;&nbsp;
				<div class="copyright-font-color">James An College</div>
			</div>
		</footer>
	</div>
</body>
</html>