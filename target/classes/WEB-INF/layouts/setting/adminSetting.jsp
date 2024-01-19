
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



</script>    



<div class="row">
    <div class="col-lg-12 bg-warning">
        <div class="card-body">
            <h5>Jac-eLearning Student Lecture</h5>
        </div>
        <iframe id="lessonVideo" src="${pageContext.request.contextPath}/image/video-thumbnail.png" width="1000" height="550" allow="autoplay; encrypted-media" allowfullscreen></iframe>
        
        <div class="card-body">
            <div class="alert alert-info" role="alert">
                <p><strong>Week</strong> <span id="academicWeek">29</span></p>
                <p id="onlineLesson" data-video-url="https://us02web.zoom.us/rec/play/nuFFIpczD7iogZYv0tivuSTdUaQDTxxHY5_M6u1_m6LN7QXixyb0rMrGn3Ser1aKe25wiF8lx7Wki7E6.i2ZHvq5tHcqkBpQr?canPlayFromShare=true&amp;from=share_recording_detail&amp;continueMode=true&amp;componentName=rec-play&amp;originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FgCZoECG_n6w6sd0H6hb8J3bStfK1-J2HFJnThllaHtKgAHn-GDabsuQrmlUpgtzl.w8toYrFjklUstG2p">
                    <li style="margin-left: 30px;"> Online Weekly Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i>
                </p>
                <p id="recordAcademicWeek" data-video-url="https://us02web.zoom.us/rec/play/5NtOifU5bIF28MWEzMO6Gp-kAW2gfmZuXpwk1DIPNlYseLkIGIV5SRGf8PaQluDFnQFgVzx-pztcDwYd.azV5kuFv4dyJqgwf?canPlayFromShare=true&amp;from=share_recording_detail&amp;continueMode=true&amp;componentName=rec-play&amp;originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FE9c3hs7nsQn5FGcptixCiL8FT80Dl4YlN6Sn7yhPW56gjfY_qU8C-taeTrE0ET-S.MMgw_nPVM4A6SR0N">
                    <li style="margin-left: 30px;">Recorded Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i>
                    </li>
                </p> 
            </div>   
            <div class="alert alert-primary" role="alert">
                <p><strong>Week</strong> <span id="academicMinusOneWeek">28</span></p>
                <p id="recordAcademicMinusOneWeek">
                    <li style="margin-left: 30px;">Recorded Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i>
                    </li>    
                </p>
            </div>
            <div class="alert alert-success" role="alert">
                <p><strong>Week</strong> <span id="academicMinusTwoWeek">27</span></p>
                <p id="recordAcademicMinusTwoWeek">
                    <li style="margin-left: 30px;">Recorded Lesson &nbsp;<i class="bi bi-caret-right-square text-primary" title="Play Video"></i>
                    </li>
                </p>
            </div>    
        </div>
    </div>
</div>


<style>
    li:hover {
        cursor: pointer;
    }
</style>
    
<script>
    // get the online lesson element and the video iframe element
    const onlineLesson = document.getElementById('onlineLesson');
    const recordAcademicWeek = document.getElementById('recordAcademicWeek');
    const lessonVideo = document.getElementById('lessonVideo');

    // define a function to handle the click event
    function handleLessonClick(element) {
        // get the video URL from the data-video-url attribute
        const videoUrl = element.getAttribute('data-video-url');
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

