
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
                document.getElementById("academicYear").innerHTML = academicYear;
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

<style>
.video-thumbnail {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    z-index: -1;
}
</style>
<div class="row">
    <div class="col-lg-12 bg-success">
        <div class="card-body">
            <h5>Progress Bar</h5>
            <!-- how to print academicWeek -->
            <p>Academic Year: <span id="academicYear"></span></p>
            <p><span id="academicWeek"></span></p>
            <!-- add a data-video-url attribute to the online weekly lesson element -->
            <p id="onlineLesson" data-video-url="https://us02web.zoom.us/rec/play/nuFFIpczD7iogZYv0tivuSTdUaQDTxxHY5_M6u1_m6LN7QXixyb0rMrGn3Ser1aKe25wiF8lx7Wki7E6.i2ZHvq5tHcqkBpQr?canPlayFromShare=true&from=share_recording_detail&continueMode=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FgCZoECG_n6w6sd0H6hb8J3bStfK1-J2HFJnThllaHtKgAHn-GDabsuQrmlUpgtzl.w8toYrFjklUstG2p">- Online Weekly Lesson</p>
            <p id="recordAcademicWeek" data-video-url="https://us02web.zoom.us/rec/play/5NtOifU5bIF28MWEzMO6Gp-kAW2gfmZuXpwk1DIPNlYseLkIGIV5SRGf8PaQluDFnQFgVzx-pztcDwYd.azV5kuFv4dyJqgwf?canPlayFromShare=true&from=share_recording_detail&continueMode=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Fus02web.zoom.us%2Frec%2Fshare%2FE9c3hs7nsQn5FGcptixCiL8FT80Dl4YlN6Sn7yhPW56gjfY_qU8C-taeTrE0ET-S.MMgw_nPVM4A6SR0N">- Recorded Lesson</p>

            <p><span id="academicMinusOneWeek"></p>
            <p>Recorded Lesson<span id="recordAcademicMinusOneWeek"></span></p>

            <p><span id="academicMinusTwoWeek"></p>
            <p>Recorded Lesson<span id="recordAcademicMinusTwoWeek"></span></p>

        </div>
    </div>
</div>
<div class="row">
    <div class="col-lg-12 bg-secondary">
        <div class="card-body">
            <!-- add an id to the iframe element -->
            <iframe id="lessonVideo" src="" width="800" height="450" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            <!-- add an image element with a class -->
            <img class="video-thumbnail" src="${pageContext.request.contextPath}/image/video-thumbnail.png" alt="Video Thumbnail">
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