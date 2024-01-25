<script>
    var academicYear;
    var academicWeek;

    $(document).ready(
        function() {
            // make an AJAX call on page load
            // to get the academic year and week
            $.ajax({
                url : '${pageContext.request.contextPath}/class/academy',
                method: "GET",
                success: function(response) {
                // save the response into the variable
                academicYear = response[0];
                academicWeek = response[1];

                // update the value of the academicYear span element
                // document.getElementById("academicYear").innerHTML = academicYear;
                // update the value of the academicWeek span element
                document.getElementById("academicWeek").innerHTML = academicWeek;
                document.getElementById("academicMinusOneWeek").innerHTML = academicWeek-1;
                document.getElementById("academicMinusTwoWeek").innerHTML = academicWeek-2;             
            },
                error: function(jqXHR, textStatus, errorThrown) {
                console.log('Error : ' + errorThrown);
                }
            });
        }
    );


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Student Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveStudentInfo(std) {
	$.ajax({
		url : '${pageContext.request.contextPath}/student/get/' + std,
		type : 'GET',
		success : function(student) {
			$('#editStudentModal').modal('show');
			// Update display info
			 console.log(student);
			$("#editId").val(student.id);
			$("#editFirstName").val(student.firstName);
			$("#editLastName").val(student.lastName);
			$("#editEmail1").val(student.email1);
			$("#editEmail2").val(student.email2);
			$("#editRelation1").val(student.relation1);
			$("#editRelation2").val(student.relation2);
			$("#editAddress").val(student.address);
			$("#editContact1").val(student.contactNo1);
			$("#editContact2").val(student.contactNo2);
			$("#editMemo").val(student.memo);
			$("#editState").val(student.state);
			$("#editBranch").val(student.branch);
			$("#editGrade").val(student.grade);
			$("#editGender").val(student.gender);
			// Set date value
			var date = new Date(student.registerDate); // Replace with your date value
			$("#editRegisterDate").datepicker('setDate', date);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


</script>    

<style>
    p#onlineLesson:hover, p#recordAcademicWeek:hover, p#recordAcademicMinusOneWeek:hover, p#recordAcademicMinusTwoWeek:hover {
        cursor: pointer;
    }
</style>


<div class="row">
    <div class="col-lg-12">
        <div class="card-body bg-primary text-center">
            <img src="${pageContext.request.contextPath}/image/logo.png" style="filter: brightness(0) invert(1);width:45px;" >
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="text-light h2">Jac-eLearning Student Lecture</span>           
        </div>
        <div class="card-body bg-primary text-right">
            <span class="card-text" onclick="retrieveStudentInfo(130365)">Dylan Quach</span>
            <a href="#" class="btn btn-primary"><i class="bi bi-box-arrow-right"></i></a>
        </div>
        <iframe id="lessonVideo" src="${pageContext.request.contextPath}/image/video-thumbnail.png" width="1000" height="550" allow="autoplay; encrypted-media" allowfullscreen></iframe>        
        <div class="card-body">
            <div class="alert alert-info" role="alert">
                <p><strong>Week</strong> <span id="academicWeek">29</span></p>
                <p id="onlineLesson" data-video-url="https://us02web.zoom.us/rec/play/YknoKqtpBgfmi5va1vUFcq8jlRTDT_A4h8Ac3w7BHWCHrLlSPK4GlEcmlYlsxUf8wC_mbJVvysx9ZBQ.VWI9jS0TJg3yrYDm?canPlayFromShare=true&from=share_recording_detail&startTime=1705901416000&componentName=rec-play&originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FC38rIDGXsOGqYoHEfzQJCMynZalimQfn5kx2QKibigR0nKBURz4aHInD7ZEWL3Py.cL_mvjc7ek-cLNwm%3FstartTime%3D1705901416000">
                    <span style="margin-left: 30px;"> 
                        Online Weekly Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i>
                    </span>
                </p>
                <p id="recordAcademicWeek" data-video-url="https://us02web.zoom.us/rec/play/1lE-D5fJpkA4mlDS-OokNXByxwl3uxQBjpAmleM6IRldvX5K36t5S-3ExngGu8LfsWyTWnFhWUKXuUmU.HzjFF8tiyh6JX92_?canPlayFromShare=true&from=share_recording_detail&continueMode=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FgCZoECG_n6w6sd0H6hb8J3bStfK1-J2HFJnThllaHtKgAHn-GDabsuQrmlUpgtzl.w8toYrFjklUstG2p">
                    <span style="margin-left: 30px;">Recorded Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i></span>
                </p> 
            </div>   
            <div class="alert alert-primary" role="alert">
                <p><strong>Week</strong> <span id="academicMinusOneWeek">28</span></p>
                <p id="recordAcademicMinusOneWeek">
                    <span style="margin-left: 30px;">Recorded Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i></span>    
                </p>
            </div>
            <div class="alert alert-success" role="alert">
                <p><strong>Week</strong> <span id="academicMinusTwoWeek">27</span></p>
                <p id="recordAcademicMinusTwoWeek">
                    <span style="margin-left: 30px;">Recorded Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i></span>
                </p>
            </div>    
        </div>
    </div>
</div>

 <!-- Edit Form Dialogue -->
<div class="modal fade" id="editStudentModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Student Information</header>
						<form id="studentEdit">
						<div class="form-row mt-2">
							<div class="col-md-4">
								<label for="editState" class="label-form">State</label> <select class="form-control" id="editState" name="editState">
								</select>
							</div>
							<div class="col-md-5">
								<label for="editBranch" class="label-form">Branch</label> 
								<select class="form-control" id="editBranch" name="editBranch">
								</select>
							</div>
							<div class="col-md-3">
								<label for="editRegisterDate" class="label-form">Registration</label> 
								<input type="text" class="form-control datepicker" id="editRegisterDate" name="editRegisterDate" placeholder="dd/mm/yyyy">
							</div>
						</div>	
						<div class="form-row mt-2">
							<div class="col-md-3">
								<label for="editId" class="label-form">ID:</label> <input type="text" class="form-control" id="editId" name="editId" readonly>
							</div>
							<div class="col-md-4">
								<label for="editFirstName" class="label-form">First Name:</label> <input type="text" class="form-control" id="editFirstName" name="editFirstName">
							</div>
							<div class="col-md-3">
								<label for="editLastName" class="label-form">Last Name:</label> <input type="text" class="form-control" id="editLastName" name="editLastName">
							</div>
							<div class="col-md-2">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
									<option value="p2">P2</option>
									<option value="p3">P3</option>
									<option value="p4">P4</option>
									<option value="p5">P5</option>
									<option value="p6">P6</option>
									<option value="s7">S7</option>
									<option value="s8">S8</option>
									<option value="s9">S9</option>
									<option value="s10">S10</option>
									<option value="s10e">S10E</option>
									<option value="tt6">TT6</option>
									<option value="tt8">TT8</option>
									<option value="tt8e">TT8E</option>
									<option value="srw4">SRW4</option>
									<option value="srw5">SRW5</option>
									<option value="srw6">SRW6</option>
									<option value="srw8">SRW8</option>
									<option value="jmss">JMSS</option>
									<option value="vce">VCE</option>
								</select>
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-3">
								<label for="editGender" class="label-form">Gender</label> <select class="form-control" id="editGender" name="editGender">
									<option value="male">Male</option>
									<option value="female">Female</option>
								</select>
							</div>
							<div class="col-md-9">
								<label for="editAddress" class="label-form">Address</label> <input type="text" class="form-control" id="editAddress" name="editAddress">
							</div>
						</div>
					
						<div class="form-row">
							<div class="col-md-12 mt-4">
								<section class="fieldset rounded" style="padding: 10px;">
									<header class="label-form" style="font-size: 0.9rem!important;">Main Contact</header>
								<div class="row">
									<div class="col-md-8">
										<input type="text" class="form-control" id="editContact1" name="editContact1" placeholder="Contact No">
									</div>
									<div class="col-md-4">
										<select class="form-control" id="editRelation1" name="editRelation1">
											<option value="mother">Mother</option>
											<option value="father">Father</option>
											<option value="sibling">Sibling</option>
											<option value="other">Other</option>
										</select>
									</div>	
								</div>
								<div class="row mt-2">
									<div class="col-md-12">
										<input type="text" class="form-control" id="editEmail1" name="editEmail1" placeholder="Email">
									</div>
								</div>
								</section>
							</div>
						</div>
						<div class="form-row">
							<div class="col-md-12 mt-4">
								<section class="fieldset rounded" style="padding: 10px;">
									<header class="label-form" style="font-size: 0.9rem!important;">Sub Contact</header>
								<div class="row">
									<div class="col-md-8">
										<input type="text" class="form-control" id="editContact2" name="editContact2" placeholder="Contact No">
									</div>
									<div class="col-md-4">
										<select class="form-control" id="editRelation2" name="editRelation2">
											<option value="mother">Mother</option>
											<option value="father">Father</option>
											<option value="sibling">Sibling</option>
											<option value="other">Other</option>
										</select>
									</div>	
								</div>
								<div class="row mt-2">
									<div class="col-md-12">
										<input type="text" class="form-control" id="editEmail2" name="editEmail2" placeholder="Email">
									</div>
								</div>
								</section>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-12">
								<label for="editMemo" class="label-form">Memo</label>
								<textarea class="form-control" style="height: 200px;" id="editMemo" name="editMemo"></textarea>
							</div>
						</div>
					</form>					
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateStudentInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>
   
<script>
    // get the online lesson element and the video iframe element
    const onlineLesson = document.getElementById('onlineLesson');
    const recordAcademicWeek = document.getElementById('recordAcademicWeek');
    const lessonVideo = document.getElementById('lessonVideo');

    // define a function to handle the click event
    function handleLessonClick(element) {
        // get the video URL from the data-video-url attribute
        const videoUrl = element.getAttribute('data-video-url');
        console.log(videoUrl);
        // set the video URL as the iframe's src attribute
        lessonVideo.setAttribute('src', videoUrl);
        // show the video by setting the iframe's display to block
        lessonVideo.style.display = 'block';
    }

    // add event listeners to the online lesson and recordAcademicWeek elements
    onlineLesson.addEventListener('click', () => {
        handleLessonClick(onlineLesson);
    });
    recordAcademicWeek.addEventListener('click', () => {
        handleLessonClick(recordAcademicWeek);
    });
</script>

