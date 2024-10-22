
<script>

const ACADEMIC_NEXT_YEAR_COURSE_SUFFIX = " (Next Year)";
var academicYear;
var academicWeek;

const ENROLMENT = 'enrolment';
// const ELEARNING = 'eLearning';
const CLASS = 'class';
const BOOK = 'book';
const ETC = 'etc';
const NEW = 'NEW';

const ONSITE = 'ONSITE';
const ONLINE = 'ONLINE';

const OVERDUE = 'Overdue';
const DISCOUNT_FREE = '100%';

$(document).ready(
	function() {

		// make an AJAX call on page load to get the academic year and week
		$.ajax({
			url : '${pageContext.request.contextPath}/class/academy',
			method: "GET",
			success: function(response) {
			// save the response into the variable
			academicYear = response[0];
			academicWeek = response[1];
			//console.log(response[1]);
			},
			error: function(jqXHR, textStatus, errorThrown) {
			console.log('Error : ' + errorThrown);
			}
		});

		$('#registerGrade').on('change',function() {
			var grade = $(this).val();
			listCourses(grade);
			listBooks(grade);
		});
		
		// remove records from basket when click on delete icon
		$('#basketTable').on('click', 'a', function(e) {
			e.preventDefault();
			var tr = $(this).closest('tr');
			// how to check data-type contains 'book' or 'class' ?
			// if it is 'book', simply remove <tr>, if it is 'class', remove all rows with the same pairId 
			var hiddens = tr.find('.data-type').text();
			if(hiddens.indexOf('|') !== -1){
				var hiddenValues = hiddens.split('|');
				if(hiddenValues[0] === BOOK){
					// how to delete current row from baskettable?
					tr.remove();
				}else if(hiddenValues[0] === CLASS){
					var pairId = tr.data('pair-id');
					// search another row with the same pairId
					$('#basketTable > tbody > tr').each(function() {
						var exist = $(this).data('pair-id');
						if(exist === pairId){
							$(this).remove();
						}
					});
				}
			}
			updateTotalBasket();
			showAlertMessage('deleteAlert', '<center><i class="bi bi-trash"></i> &nbsp;&nbsp Item is now removed from My Lecture</center>');
		});

		// Add event listeners to the input fields within the same row
		$('#basketTable').on('input', '.onsiteStart, .onsiteEnd, .onsiteWeeks, .onsiteCredit', function () {
			var $onsiteRow = $(this).closest('tr');  // Find the closest onsite row
			// how to set .discount = 0?
			$onsiteRow.find('.discount').text(0);
			var pairId = $onsiteRow.data('pair-id');  // Get the pair ID
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').not($onsiteRow);  // Find the corresponding online row

			syncValues($onsiteRow, $onlineRow);  // Pass both rows to the syncValues function
   		});

	}
);


//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Sync values between onsite and online rows    
//////////////////////////////////////////////////////////////////////////////////////////////////////
function syncValues($onsiteRow, $onlineRow) {
    // Parse integer values from the onsite start and end dates within the same row
    var onsiteStartValue = parseInt($onsiteRow.find('.onsiteStart').text(), 10);
    $onlineRow.find('.onlineStart').text(onsiteStartValue);

    var onsiteEndValue = parseInt($onsiteRow.find('.onsiteEnd').text(), 10);
    $onlineRow.find('.onlineEnd').text(onsiteEndValue);

    var onsiteWeeksValue = parseInt($onsiteRow.find('.onsiteWeeks').text(), 10);
    $onlineRow.find('.onlineWeeks').text(onsiteWeeksValue);

    var onsiteCreditValue = parseInt($onsiteRow.find('.onsiteCredit').text(), 10);
    $onlineRow.find('.onlineCredit').text(onsiteCreditValue);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Search Course based on Grade    
//////////////////////////////////////////////////////////////////////////////////////////////////////
function listCourses(grade) {
	// clear 'courseTable' table body
	$('#courseTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/class/coursesByGrade',
		type : 'GET',
		data : {
			grade : grade
		},
		success : function(data) {
			$.each(data, function(index, value) {
				const cleaned = cleanUpJson(value);
				//console.log(cleaned);
				var row = $('<tr class="d-flex">');
				row.append($('<td>').addClass('hidden-column').text(value.id));
				row.append($('<td class="col-1"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>'));
				var subjectsString = '';
				if(value.subjects != null && value.subjects.length > 0){	
					subjectsString = value.subjects.map(function(subject) {
						return subject.name;
					}).join(', ');
				}
				row.append($('<td class="smaller-table-font course-title col-10" style="padding-left: 20px;">').html(value.name + ' - ' + value.description + '  [' + subjectsString + ']'));
				row.append($("<td class='col-1' onclick='addClassToBasket(" + cleaned + ","  + grade + ")''>").html('<a href="javascript:void(0)" data-toggle="tooltip" title="Add Class"><i class="bi bi-plus-circle"></i></a>'));
				$('#courseTable > tbody').append(row);
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}
	
//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Search Book based on Grade  
//////////////////////////////////////////////////////////////////////////////////////////////////////
function listBooks(grade) {
	// clear 'bookTable' table body
	$('#bookTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/book/listGrade',
		type : 'GET',
		data : {
			grade : grade,
		},
		success : function(data) {
			$.each(data, function(index, value) {
				if (value.price === undefined) {
					value.price = 0; // Set price to 0 if it's undefined
				}
				const cleaned = cleanUpJson(value);
				//console.log(cleaned);
				var row = $('<tr class="d-flex">');
				row.append($('<td>').addClass('hidden-column').text(value.id));
				row.append($('<td class="col-1"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>'));
				row.append($('<td class="smaller-table-font col-5">').text(value.name));
				// Assuming value.subjects is an array of objects with a 'name' property
				var subjectsString = '';
				if(value.subjects != null && value.subjects.length > 0){	
					subjectsString = value.subjects.map(function(subject) {
						return subject.name;
					}).join(', ');
				}
				row.append($('<td class="small align-middle smaller-table-font col-4">').text(subjectsString));				
				row.append($('<td class="smaller-table-font col-1 text-right pr-1">').text(Number(value.price).toFixed(2)));
				row.append($("<td class='col-1' onclick='addBookToBasket(" + cleaned +  ")''>").html('<a href="javascript:void(0)" data-toggle="tooltip" title="Add Book"><i class="bi bi-plus-circle"></i></a>'));
				$('#bookTable > tbody').append(row);
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Add class to basket
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addClassToBasket(value, gradePair) {
var state = $('#formState').val();
var branch = $('#formBranch').val();

let grade = value.grade;	  
let year = value.year;	
let isOnline = value.online;
$.ajax({
	url: isOnline ? '${pageContext.request.contextPath}/class/onlineClassByCourse' : '${pageContext.request.contextPath}/class/classesByCourse',
	type: 'GET',
	data: {
	  courseId: value.id,
	  year: year,
	  state : state,
	  branch : branch	
	},
	success: function(data) {
		//console.log(data);
		// console.log(value);
		var start_week, end_week;        
		if (value.year == academicYear) {
			start_week = parseInt(academicWeek);
			end_week = parseInt(academicWeek) + 9;
			if (end_week >= 49) {
			end_week = 49;
			}
		} else {
			start_week = 1;
			end_week = 10;
		}    
		var row = $('<tr class="d-flex" data-pair-id="' + gradePair + '">');
		// dynamic clazz id assign
		var dropdown = $('<select class="clazzChoice">');
		$.each(data, function(index, clazz) {
			var option = $('<option>').text(dayName(clazz.day)).val(clazz.id).data('price', clazz.price);
			dropdown.append(option);
		});
		// Get the value of the first option
		var initialValue = dropdown.find('option:first').val();
		var selectedPrice = dropdown.find('option:first').data('price');
		// Initialize the hidden column with the initial value
		var hiddenColumn = $('<td>').addClass('hidden-column data-type').text(CLASS +'|' + initialValue);
		// Initialize the price cell
		var priceCell = $('<td class="smaller-table-font text-center price">').text(selectedPrice);
		dropdown.on('change', function() {
			var selectedValue = $(this).val();
			selectedPrice = dropdown.find('option:selected').data('price');
			// Update the hidden column's text with the selected value
			hiddenColumn.text(CLASS +'|' + selectedValue);
			// Update the price cell's text with the selected value
			priceCell.text(selectedPrice);
			// Trigger updating amount as well
			priceCell.trigger('priceChanged');
		});

		// update amount as initial value
		priceCell.on('priceChanged', function(){
			row.find('.amount').text((10 * priceCell.text()).toFixed(2));				
		});

		row.append(hiddenColumn);
		row.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>')); // item
		row.append($('<td class="smaller-table-font name">').text(value.name)); // name
		row.append($('<td class="smaller-table-font day">').append(dropdown)); // day
		row.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year

		var startWeekCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('start-week onsiteStart').text(start_week); // start week
		startWeekCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var endWeekValue = parseInt(row.find('.end-week').text()); // Get the value from class end-week cell within the same row
			var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell within the same row
			var creditValue = parseInt(row.find('.credit').text()); // Get the value from class credit cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			// Update weeks & amount within the same row
			row.find('.weeks').text(((endWeekValue - updatedValue) + 1) + creditValue);
			var originalPrice = (((endWeekValue - updatedValue) + 1) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class two cell within the same row with the calculated value
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(startWeekCell);
		});
		row.append(startWeekCell);
		
		var endWeekCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('end-week onsiteEnd').text(end_week); // end week
			endWeekCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var startWeekValue = parseInt(row.find('.start-week').text()); // Get the value from class start-week cell within the same row
			var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell within the same row
			var creditValue = parseInt(row.find('.credit').text()); // Get the value from class credit cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			// update weeks & amount within the same row
			row.find('.weeks').text(((updatedValue - startWeekValue) + 1) + creditValue);
			var originalPrice = (((updatedValue - startWeekValue) + 1) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class two cell within the same row with the calculated value
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(endWeekCell);
		});
		row.append(endWeekCell);

		var weeksCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('weeks onsiteWeeks').text((end_week - start_week) + 1);// weeks  
		weeksCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var startWeekValue = parseInt(row.find('.start-week').text()); // Get the value from class start-week cell within the same row
			var creditValue = parseInt(row.find('.credit').text()); // Get the value from class credit cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			// update end-week & amount within the same row
			row.find('.end-week').text(updatedValue + startWeekValue - 1);
			var originalPrice = ((updatedValue - creditValue) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class amount cell within the same row with the calculated value
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(weeksCell);		
		});
		row.append(weeksCell);

		var creditCell = $('<td class="smaller-table-font text-center" contenteditable="true">').attr('id','onsiteCredit').addClass('credit onsiteCredit').text(0); // credit
		var previousCredit = parseInt(creditCell.text());
		creditCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var startWeekValue = parseInt(row.find('.start-week').text()); // Get the value from class start-week cell within the same row
			var endWeekValue = parseInt(row.find('.end-week').text()); // Get the value from class end-week cell within the same row
			var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			var originalEndWeekValue = endWeekValue;
			if (previousCredit == 0) { // never use credit before
				// update end-week
				row.find('.end-week').text(endWeekValue + updatedValue);
				// update weeks
				row.find('.weeks').text(weeksValue + updatedValue);
			} else if (previousCredit > 0) { // already use credit
				originalEndWeekValue = endWeekValue - previousCredit;
				// update end-week
				row.find('.end-week').text(originalEndWeekValue + updatedValue);
				// update weeks
				row.find('.weeks').text(originalEndWeekValue - startWeekValue + 1 + updatedValue);
			}
			var originalPrice = ((parseInt(row.find('.weeks').text()) - updatedValue) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class amount cell within the same row with the calculated value
			previousCredit = updatedValue; // Update previousCredit variable with the new updatedValue
			// Add keypress event to handle Enter key
			creditCell.on('keypress', function(event) {
				if (event.which === 13) { // Enter key
					event.preventDefault();
					$(this).blur(); // Remove focus and stop editing
				}
			});
		});
		row.append(creditCell);

		var discountCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('discount').text(0); // discount
		discountCell.on('input', function() {
			var updatedValue = $(this).text();
			var row = $(this).closest('tr'); // Get the parent row of the discount cell
			if (updatedValue === null || updatedValue === '' || updatedValue === '0') {
				var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell in the same row
				var creditValue = parseFloat(row.find('.credit').text()); // Get the value from class credit cell in the same row
				var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell in the same row
				var originalPrice = (weeksValue - creditValue) * priceValue;
				// update amount
				row.find('.amount').text(originalPrice.toFixed(2)); // Update class amount cell in the same row with the calculated value
			} else if (updatedValue.toString().includes('%')) {
				// calculate discount percentage
				// remove '%' from updatedValue
				updatedValue = parseInt(updatedValue.replace('%', ''));
				var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell in the same row
				var creditValue = parseFloat(row.find('.credit').text()); // Get the value from class credit cell in the same row
				var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell in the same row
				var originalPrice = (weeksValue - creditValue) * priceValue;
				var discountedPrice = originalPrice * (updatedValue / 100);
				// update amount
				row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update amount cell in the same row with the calculated value
			} else {
				// calculate discount amount
				var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell in the same row
				var creditValue = parseFloat(row.find('.credit').text()); // Get the value from class credit cell in the same row
				var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell in the same row
				var originalPrice = (weeksValue - creditValue) * priceValue;
				// update amount
				row.find('.amount').text((originalPrice - updatedValue).toFixed(2)); // Update amount cell in the same row with the calculated value
			}
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(discountCell);
		});
		row.append(discountCell);
		
		row.append(priceCell);

		row.append($('<td class="smaller-table-font text-center">').addClass('amount').text(((weeksCell.text() * priceCell.text())).toFixed(2))); // amount					
		row.append($('<td>').html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete class"><i class="bi bi-trash"></i></a>'));
		row.append($('<td class="hidden-column enrolId">').text('')); // enrolId
		row.append($('<td class="hidden-column invoiceId">').text('')); // invoiceId
		row.append($('<td class="hidden-column online">').text(false)); // online			
		row.append($('<td class="hidden-column grade">').text(value.grade)); // grade
		row.append($('<td class="hidden-column description">').text(value.description)); // description
		$('#basketTable > tbody').prepend(row);
		
		// check if it is 'Online'
		if(!value.online){
			//console.log('Online needs : ' + value);
			var clazzId = 0;
			var isNewClazz = (value.description.indexOf(ACADEMIC_NEXT_YEAR_COURSE_SUFFIX) !== -1);
			$.ajax({
				url: '${pageContext.request.contextPath}/class/onlineId',
				type: 'GET',
				data: {
					grade: grade,
					year: year
					// state: state,
					// branch: branch
				},
				success: function(data) {
					// if any online course is found with grade & year
					if((data !== '') && (data > 0)){
						clazzId = data;
						$('#courseTable > tbody > tr').each(function() {
							var title = $(this).find('.course-title').text();
							//debugger;
							if(title.toUpperCase().indexOf(ONLINE) !== -1){ // 2 times check !!!!!
								var isNewOnlineClazz = (title.indexOf(ACADEMIC_NEXT_YEAR_COURSE_SUFFIX) !== -1);
								// check if onsite class matches proper online class - not next year online class
								if(isNewClazz==isNewOnlineClazz){
									var clazzName = '';
									var clazzDescription = '';
									if(title.indexOf('-') !== -1){
										clazzName = title.split('-')[0].trim();
										clazzDescription = title.split('-')[1].trim();
									}
									var row = $('<tr class="d-flex" data-pair-id=' + gradePair + '>');
									row.append($('<td>').addClass('hidden-column data-type').text(CLASS +'|' + clazzId));
									row.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>')); // item
									row.append($('<td class="smaller-table-font name">').text(clazzName)); // name
									row.append($('<td class="smaller-table-font day">').text('All')); // day
									row.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year
									var onlineStartWeek = startWeekCell.clone().removeClass('onsiteStart').addClass('onlineStart').text(start_week);
									row.append(onlineStartWeek);
									var onlineEndWeek = endWeekCell.clone().removeClass('onsiteEnd').addClass('onlineEnd').text(end_week);
									row.append(onlineEndWeek);
									var onlineWeeks = weeksCell.clone().removeClass('onsiteWeeks').addClass('onlineWeeks').text((end_week - start_week) + 1);
									row.append(onlineWeeks);
									row.append($('<td class="smaller-table-font text-center credit onlineCredit" contenteditable="true">').text(0));
									row.append($('<td class="smaller-table-font text-center discount" contenteditable="true">').text('100%'));
									row.append($('<td class="smaller-table-font text-center price">').text(0)); // price
									row.append($('<td class="smaller-table-font text-center">').addClass('amount').text(0)); // amount					
									row.append($('<td>'));
									row.append($('<td class="hidden-column enrolId">').text('')); // enrolId
									row.append($('<td class="hidden-column invoiceId">').text('')); // invoiceId
									row.append($('<td class="hidden-column online">').text(true)); // online				
									row.append($('<td class="hidden-column grade">').text(value.grade)); // grade
									row.append($('<td class="hidden-column description">').text(clazzDescription)); // description
									$('#basketTable > tbody').append(row);	
								}	

							}
						});
					}
				},
				error: function(xhr, status, error) {
					console.log('Error : ' + error);
				}
			});	
		}	
		// update total
		updateTotalBasket();
		showAlertMessage('addAlert', '<center><i class="bi bi-mortarboard"></i> &nbsp;&nbsp' + value.description + ' added to My Lecture</center>');
	}
  });
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Add book to basket
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addBookToBasket(value, index){
	// console.log(value);
	// console.log(index);
	// if book is already in basket, skip
	if(isSameRowExisting(BOOK, value.id)){
		showAlertMessage('warningAlert', '<center><i class="bi bi-book"></i> &nbsp;&nbsp' + value.name +' is already in My Lecture</center>');
		return;
	}
	var row = $('<tr class="d-flex">');
	row.append($('<td>').addClass('hidden-column').addClass('data-type').text(BOOK + '|' + value.id)); // 0
	row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>')); // item
	row.append($('<td class="smaller-table-font name" style="width: 36%;">').text(value.name)); // name
	row.append($('<td style="width: 7%;">'));
	row.append($('<td style="width: 6%;">'));
	row.append($('<td style="width: 6%;">'));
	row.append($('<td style="width: 6%;">'));
	row.append($('<td style="width: 4%;">'));
	row.append($('<td style="width: 7%;">'));
	row.append($('<td style="width: 8%;">')); // price
	// row.append($('<td class="smaller-table-font text-center price" style="width: 11%;">').text(value.price.toFixed(2)));
	row.append($('<td class="smaller-table-font text-center price amount" style="width: 11%;">').text(Number(value.price).toFixed(2)));
	row.append($('<td style="width: 4%;">').html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete book"><i class="bi bi-trash"></i></a>')); // Action
	row.append($('<td>').addClass('hidden-column').addClass('grade').text(value.grade)); 
	row.append($('<td>').addClass('hidden-column').addClass('materialId').text('')); 
	row.append($('<td>').addClass('hidden-column').addClass('invoiceId').text('')); 
		
	$('#basketTable > tbody').append(row);

	// update total	
	updateTotalBasket();
	
	// Automatically dismiss the alert after 2 seconds
	showAlertMessage('addAlert', '<center><i class="bi bi-book"></i> &nbsp;&nbsp' + value.name +' added to My Lecture</center>');
}
	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Associate registration with Student 
//////////////////////////////////////////////////////////////////////////////////////////////////////
function associateRegistration(){
	// get id from 'formId'
	const studentId = $('#formId').val();
	// if id is null, show alert and return
	if (studentId == null || studentId == '') {
		//warn if student id  is empty
		$('#warning-alert .modal-body').text('Please search student before apply');
		$('#warning-alert').modal('toggle');
		return; 
	}

	// var elearnings = [];
	var enrolData = [];
	var bookData = [];

	$('#basketTable tbody tr').each(function() {
		// in case of update, enrolId is not null
		//debugger;
		var clazzId = null;
		var bookId = null;
		var hiddens = $(this).find('.data-type').text();
		if(hiddens.indexOf('|') !== -1){
			var hiddenValues = hiddens.split('|');
			if(hiddenValues[0] === BOOK){
				bookId = hiddenValues[1];
				var materialId = $(this).find('.materialId').text();
				var invoiceId = $(this).find('.invoiceId').text();
				var book = {
					"id" : materialId,
					"invoiceId" : invoiceId,
					"bookId" : bookId
				};
				bookData.push(book);
				//return true;
			}else if(hiddenValues[0] === CLASS){
				clazzId = hiddenValues[1];
				enrolData.id = $(this).find('.enrolId').text();
				enrolData.startWeek = $(this).find('.start-week').text();
				enrolData.endWeek = $(this).find('.end-week').text();
				enrolData.price = $(this).find('.price').text();
				enrolData.grade = $(this).find('.grade').text();
				enrolData.year = $(this).find('.year').text();
				enrolData.name = $(this).find('.name').text();
				enrolData.invoiceId = $(this).find('.invoiceId').text();
				enrolData.amount = $(this).find('.amount').text();
				enrolData.discount = $(this).find('.discount').text();
				enrolData.credit = $(this).find('.credit').text();
				enrolData.weeks = $(this).find('.weeks').text();
				enrolData.online = $(this).find('.online').text();
				enrolData.paid = $(this).find('.paid').text();
				enrolData.extra = $(this).find('.extra').text();
				enrolData.day = $(this).find('.clazzChoice option:selected').text();
				if(enrolData.day === ""){ // if day is not selected from dropdown
					enrolData.day = $(this).find('.day').text()
				}
				var clazz = {
					"id" : enrolData.id,
					"startWeek" : enrolData.startWeek,
					"endWeek" : enrolData.endWeek,
					"clazzId" : clazzId,
					"price" : enrolData.price,
					"grade" : enrolData.grade,
					"year" : enrolData.year,
					"name" : enrolData.name,
					"invoiceId" : enrolData.invoiceId,
					"amount" : enrolData.amount,
					"discount" : enrolData.discount,
					"credit" : enrolData.credit,
					"weeks" : enrolData.weeks,
					"day" : enrolData.day,
					"online" : enrolData.online,
					"paid" : enrolData.paid,
					"extra" : enrolData.extra,
					"studentId" : studentId
				};
				enrolData.push(clazz);
			}
		}
		// how to jump to next <tr>             
		return true;    
	});

	// Promise ajax call
	function associateClazz(studentId, enrolData) {
		return new Promise((resolve, reject) => {
			$.ajax({
				url: '${pageContext.request.contextPath}/enrolment/associateClazz/' + studentId,
				method: 'POST',
				data: JSON.stringify(enrolData),
				contentType: 'application/json',
				success: function(response) {
					clearInvoiceTable();

					if(response.length > 0){
						$.each(response, function(index, value){
							// if extra is NEW, it requires updating enrolment id in basket table
							if(value.extra != null && value.extra === NEW){
								$('#basketTable > tbody > tr').each(function() {
									var hiddens = $(this).find('.data-type').text();
									if ((hiddens.indexOf(CLASS) !== -1) && (hiddens.indexOf('|') !== -1)) {
										var hiddenValues = hiddens.split('|');
										if(hiddenValues[1] === value.clazzId){
											$(this).find('.enrolId').text(value.id);
											$(this).find('.invoiceId').text(value.invoiceId);
											$(this).find('.clazzChoice').prop('disabled', true);        
										}
									}
								});
							}
							let isFreeOnline = value.online && value.discount === DISCOUNT_FREE;
							if(!isFreeOnline){
								addEnrolmentToInvoiceList(value, 0);
							}
						});
					} else {
						clearEnrolmentBasket();
						updateLatestInvoiceId(enrolData.invoiceId);
					}
					resolve();
				},
				error: function(xhr, status, error) {
					console.error(error);
					reject(error);
				}
			});
		});
	}

	function associateBook(studentId, bookData) {
		return new Promise((resolve, reject) => {
			$.ajax({
				url: '${pageContext.request.contextPath}/enrolment/associateBook/' + studentId,
				method: 'POST',
				data: JSON.stringify(bookData),
				contentType: 'application/json',
				success: function(response) {
					removeBookFromInvoiceList();
					if(response.length > 0){
						$.each(response, function(index, value){
							$('#basketTable > tbody > tr').each(function() {
								var hiddens = $(this).find('.data-type').text();
								if ((hiddens.indexOf(BOOK) !== -1) && (hiddens.indexOf('|') !== -1)) {
									var hiddenValues = hiddens.split('|');
									if(hiddenValues[1] === value.bookId){
										$(this).find('.materialId').text(value.id);
										$(this).find('.invoiceId').text(value.invoiceId);
									}
								}
							});
							addBookToInvoiceList(value, 0);
						});
					} else {
						updateLatestInvoiceId(bookData.invoiceId);
					}
					resolve();
				},
				error: function(xhr, status, error) {
					console.error(error);
					reject(error);
				}
			});
		});
	}

	function associatePayment(studentId) {
		return new Promise((resolve, reject) => {
			$.ajax({
				url: '${pageContext.request.contextPath}/enrolment/associatePayment/' + studentId,
				method: 'POST',
				contentType: 'application/json',
				success: function(response) {
					// console.log(response);
					removePaymentFromInvoiceList();
					if(response.length > 0){
						$.each(response, function(index, value){
							addPaymentToInvoiceList(value, 0);
						});
					}
					resolve();
				},
				error: function(xhr, status, error) {
					console.error(error);
					reject(error);
				}
			});
		});
	}

	// call one by one : associateClazz -> associateBook -> associatePayment
	associateClazz(studentId, enrolData)
		.then(() => associateBook(studentId, bookData))
		.then(() => associatePayment(studentId))
		.then(() => {
			retrieveAttendance(studentId);
			var rowCount = $('#basketTable tbody tr').length;
		})
		.catch(error => {
			console.error('Error:', error);
		});

}
	
//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Retrieve Enroloment & Update Invoice Table
//////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveEnrolment(studentId){
	
	// Promise ajax call - get last 3 enrolments
	function getEnrols(studentId) {
		return new Promise((resolve, reject) => {
		$.ajax({
				url: '${pageContext.request.contextPath}/enrolment/search/student/' + studentId,
				method: 'GET',
				success: function(response) {
					// Handle the response
					for (let index = response.length - 1; index >= 0; index--) {
						let value = response[index];
						// console.log(index + ' -- ' + value);

						$.each(value, function(count, data) {
							if (index == 0) {
								// console.log('Top >>>>>>> index : ' + index + ' -- count :' + count + ' --> ' + data);
								updateInvoiceTableWithTop(data, index);
							} else {
								// console.log('Rest <<<<<<< index : ' + index + ' -- count :' + count + ' --> ' + data);
								updateInvoiceTableWithRest(data, index);
							}
						});
					} // end of for loop
					resolve();
				},
				error: function(xhr, status, error) {
					// Handle the error
					console.error(error);
					reject(error);
				}
			});
		});
	}

	// Promise ajax call - update balance amount
	function updateBalance() {
		return new Promise((resolve, reject) => {
			var hiddenInvoiceId = parseInt($('#hiddenInvoiceId').val());
			$.ajax({
				url: '${pageContext.request.contextPath}/invoice/amount/' + hiddenInvoiceId,
				method: 'GET',
				success: function(response) {
					$("#rxAmount").text(response.toFixed(2));
					if(parseFloat(response) > 0){
						$('#paymentBtn').prop('disabled', false);
					}else{
						$('#paymentBtn').prop('disabled', true);
					}
					resolve();
				},
				error: function(xhr, status, error) {
						// Handle the error
						console.error(error);
						$("#rxAmount").text(0);
						reject(error);
				}
			});
		});
	}

	// call one by one : getEnrols -> updaateBalance
	getEnrols(studentId)
	.then(() => updateBalance())
	.catch(error => {
		console.error('Error:', error);
	});
}








//////////////////////////////////////////////////////////////////////////////////////////////////////
// 	Update Invoice Table with lastest EnrolmentDTO
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInvoiceTableWithTop(value, rowCount){

	if (value.hasOwnProperty('extra')) {

		// update my lecture table
		var row = $('<tr class="d-flex" data-pair-id=' + value.grade + '>');
		row.append($('<td>').addClass('hidden-column').addClass('data-type').text(CLASS + '|' + value.clazzId));
		if(value.extra === OVERDUE){
			row.append($('<td class="text-center"><i class="bi bi-mortarboard-fill text-danger" data-toggle="tooltip" title="Overdue"></i></td>')); // item
		}else{
			row.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>')); // item
		}
		//row.append($('<td class="text-center"><i class="bi bi-mortarboard" title="class"></i></td>')); // item
		row.append($('<td class="smaller-table-font name">').text(value.name)); // name
		row.append($('<td class="smaller-table-font day">').text(dayName(value.day))); // day
		row.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year

		var startWeekCell = value.online ? $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('start-week onlineStart').text(value.startWeek) : $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('start-week onsiteStart').text(value.startWeek); // start week;
		startWeekCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var endWeekValue = parseInt(row.find('.end-week').text()); // Get the value from class end-week cell within the same row
			var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell within the same row
			var creditValue = parseInt(row.find('.credit').text()); // Get the value from class credit cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			// Update weeks & amount within the same row
			row.find('.weeks').text(((endWeekValue - updatedValue) + 1) + creditValue);
			var originalPrice = (((endWeekValue - updatedValue) + 1) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class two cell within the same row with the calculated value
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(startWeekCell);
		});
		row.append(startWeekCell);

		var endWeekCell = value.online ? $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('end-week onlineEnd').text(value.endWeek) : $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('end-week onsiteEnd').text(value.endWeek); // end week;
		endWeekCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var startWeekValue = parseInt(row.find('.start-week').text()); // Get the value from class start-week cell within the same row
			var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell within the same row
			var creditValue = parseInt(row.find('.credit').text()); // Get the value from class credit cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			// update weeks & amount within the same row
			row.find('.weeks').text(((updatedValue - startWeekValue) + 1) + creditValue);
			var originalPrice = (((updatedValue - startWeekValue) + 1) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class two cell within the same row with the calculated value
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(endWeekCell);
		});
		row.append(endWeekCell);

		var weeksCell = value.online ? $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('weeks onlineWeeks').text((value.endWeek - value.startWeek) + 1) : $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('weeks onsiteWeeks').text((value.endWeek - value.startWeek) + 1); // weeks;
		weeksCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var startWeekValue = parseInt(row.find('.start-week').text()); // Get the value from class start-week cell within the same row
			var creditValue = parseInt(row.find('.credit').text()); // Get the value from class credit cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			// update end-week & amount within the same row
			row.find('.end-week').text(updatedValue + startWeekValue - 1);
			var originalPrice = ((updatedValue - creditValue) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class amount cell within the same row with the calculated value
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(weeksCell);
		});
		row.append(weeksCell);

		var creditCell = value.online ? $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('credit onlineCredit').text(value.credit) : $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('credit onsiteCredit').text(value.credit); // credit;				
		var previousCredit = parseInt(creditCell.text());
		creditCell.on('input', function() {
			var updatedValue = isNaN(parseInt($(this).text())) ? 0 : parseInt($(this).text());
			var row = $(this).closest('tr'); // Get the closest <tr> element
			var startWeekValue = parseInt(row.find('.start-week').text()); // Get the value from class start-week cell within the same row
			var endWeekValue = parseInt(row.find('.end-week').text()); // Get the value from class end-week cell within the same row
			var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell within the same row
			var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell within the same row
			var discountValue = parseFloat(row.find('.discount').text()); // Get the value from class discount cell within the same row
			var originalEndWeekValue = endWeekValue;
			if (previousCredit == 0) { // never use credit before
				// update end-week
				row.find('.end-week').text(endWeekValue + updatedValue);
				// update weeks
				row.find('.weeks').text(weeksValue + updatedValue);
			} else if (previousCredit > 0) { // already use credit
				originalEndWeekValue = endWeekValue - previousCredit;
				// update end-week
				row.find('.end-week').text(originalEndWeekValue + updatedValue);
				// update weeks
				row.find('.weeks').text(originalEndWeekValue - startWeekValue + 1 + updatedValue);
			}
			var originalPrice = ((parseInt(row.find('.weeks').text()) - updatedValue) * priceValue);
			var discountedPrice = parseFloat(originalPrice * (discountValue / 100));
			row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update class amount cell within the same row with the calculated value
			previousCredit = updatedValue; // Update previousCredit variable with the new updatedValue
			creditCell.on('keypress', function(event) {
				if (event.which === 13) { // Enter key
					event.preventDefault();
					$(this).blur(); // Remove focus and stop editing
				}
			});
		});
		row.append(creditCell);

		// row.append($('<td class="smaller-table-font text-center discount" contenteditable="true">').text(value.discount)); // discount
		var discountCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('discount').text(value.discount); // discount
		discountCell.on('input', function() {
			var updatedValue = $(this).text();
			var row = $(this).closest('tr'); // Get the parent row of the discount cell
			if (updatedValue === null || updatedValue === '' || updatedValue === '0') {
				var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell in the same row
				var creditValue = parseFloat(row.find('.credit').text()); // Get the value from class credit cell in the same row
				var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell in the same row
				var originalPrice = (weeksValue - creditValue) * priceValue;
				// update amount
				row.find('.amount').text(originalPrice.toFixed(2)); // Update class amount cell in the same row with the calculated value
			} else if (updatedValue.toString().includes('%')) {
				// calculate discount percentage
				// remove '%' from updatedValue
				updatedValue = parseInt(updatedValue.replace('%', ''));
				var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell in the same row
				var creditValue = parseFloat(row.find('.credit').text()); // Get the value from class credit cell in the same row
				var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell in the same row
				var originalPrice = (weeksValue - creditValue) * priceValue;
				var discountedPrice = originalPrice * (updatedValue / 100);
				// update amount
				row.find('.amount').text((originalPrice - discountedPrice).toFixed(2)); // Update amount cell in the same row with the calculated value
			} else {
				// calculate discount amount
				var weeksValue = parseInt(row.find('.weeks').text()); // Get the value from class weeks cell in the same row
				var creditValue = parseFloat(row.find('.credit').text()); // Get the value from class credit cell in the same row
				var priceValue = parseFloat(row.find('.price').text()); // Get the value from class price cell in the same row
				var originalPrice = (weeksValue - creditValue) * priceValue;
				// update amount
				row.find('.amount').text((originalPrice - updatedValue).toFixed(2)); // Update amount cell in the same row with the calculated value
			}
			// update total & keypress event to handle Enter key
			cellEnterKeyUpdateTotalBasket(discountCell);
		});
		row.append(discountCell);

		row.append($('<td class="smaller-table-font text-center price">').text(value.price)); // price

		var totalEnrolPrice = ((weeksCell.text()-(creditCell.text()))* value.price);
		var discount = defaultIfEmpty(discountCell.text(), 0);	
		if(discount.toString().includes('%')){
			discount = discount.replace('%', '');
			totalEnrolPrice = totalEnrolPrice - (totalEnrolPrice * (discount / 100));
		}else{
			totalEnrolPrice = totalEnrolPrice - discount;
		}

		row.append($('<td class="smaller-table-font text-center">').addClass('amount').text(totalEnrolPrice.toFixed(2))); // amount				

		let freeOnline = value.online && value.discount === DISCOUNT_FREE;	
		var deleteIcon =(freeOnline) ? $("<td>") : $("<td>").html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete class"><i class="bi bi-trash"></i></a>');
		row.append(deleteIcon);

		row.append($('<td class="hidden-column invoiceId">').text(value.invoiceId)); // invoiceId
		row.append($('<td class="hidden-column online">').text(value.online)); // online	
		row.append($('<td class="hidden-column grade">').text(value.grade)); // grade
		row.append($('<td class="hidden-column description">').text(value.description)); // description
		row.append($('<td class="hidden-column enrolId">').text(value.id)); // enrolmentId
		row.append($('<td class="hidden-column invoiceAmount">').text(value.amount)); // invoice amount	
		row.append($('<td class="hidden-column paid">').text(value.paid)); // paid	
		row.append($('<td class="hidden-column extra">').text(value.extra)); // extra	

		$('#basketTable > tbody').append(row);

		// update invoice table with Enrolment unless free online class
		if(!freeOnline){
			addEnrolmentToInvoiceList(value, rowCount);
		}
	}else if (value.hasOwnProperty('bookId')) { // It is an MaterialDTO object

		// update my lecture table
		var row = $('<tr class="d-flex">');
		row.append($('<td>').addClass('hidden-column').addClass('data-type').text(BOOK + '|' + value.bookId)); // 0
		row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>')); // item
		row.append($('<td class="smaller-table-font" style="width: 36%;">').text(value.name)); // name
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 4%;">'));
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 8%;">')); // price
		row.append($('<td class="smaller-table-font text-center price amount" style="width: 11%;">').text(value.price.toFixed(2)));
		row.append($("<td style='width: 4%;'>").html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete book"><i class="bi bi-trash"></i></a>')); // Action
		row.append($('<td class="hidden-column grade">').text(value.grade));
		row.append($('<td class="hidden-column materialId">').text(value.id)); 
		row.append($('<td class="hidden-column invoiceId">').text(value.invoiceId)); 

		$('#basketTable > tbody').append(row);
		// update invoice table with Book
		addBookToInvoiceList(value, rowCount);

	}else{//} if (value.hasOwnProperty('upto')) { // It is an PaymentDTO object
		// update invoice table with Payment
		addPaymentToInvoiceList(value, rowCount);
	}

	// update basket total
	updateTotalBasket();

}



//////////////////////////////////////////////////////////////////////////////////////////////////////
// 	Update Invoice Table with 2nd/3rd last EnrolmentDTO
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInvoiceTableWithRest(value, rowCount){

	if (value.hasOwnProperty('extra')) {

		let freeOnline = value.online && value.discount === DISCOUNT_FREE;	
		// update invoice table with Enrolment unless free online class
		if(!freeOnline){
			addEnrolmentToInvoiceList(value, rowCount);
		}
	}else if (value.hasOwnProperty('bookId')) { // It is an MaterialDTO object

		// update invoice table with Book
		addBookToInvoiceList(value, rowCount);

	}else{//} if (value.hasOwnProperty('upto')) { // It is an PaymentDTO object
		// update invoice table with Payment
		addPaymentToInvoiceList(value, rowCount);
	}

}










//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Check same row exists in basketTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function isSameRowExisting(dataType, id) {
	var isExist = false;
	$('#basketTable > tbody > tr').each(function() {
		var exist = $(this).find('.data-type').text();
		if(exist.indexOf('|') !== -1){
			var hiddenValues = exist.split('|');
			//console.log(hiddenValues[1]);
			if(hiddenValues[0] === dataType && hiddenValues[1] === id){
				isExist = true;retrieveEnrolment
			}
		}
	});
	return isExist;
}
	
//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Clean basketTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function clearEnrolmentBasket(){
	$('#basketTable > tbody').empty();
	updateTotalBasket();
}
	
//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Pop-up simple toast message
//////////////////////////////////////////////////////////////////////////////////////////////////////
function showAlertMessage(elementId, message) { 
	document.getElementById(elementId).innerHTML = message; 
	$("#" + elementId).fadeTo(2000, 500).slideUp(500, 
		function(){ 
			$("#" + elementId).slideUp(500); 
		}
	);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Update Total Amount in Basket
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateTotalBasket() {
	var total = 0;
	$('#basketTable tbody tr').each(function() {
		var amount = parseFloat($(this).find('td.amount').text());
		if (!isNaN(amount)) {
			total += amount;
		}
	});
	// Update the 'basketTotal' cell
	$('#basketTotal').text(total.toFixed(2)); // Adjust toFixed(2) for desired decimal places
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Update Total Amount in Basket & Enter key event in the cell
//////////////////////////////////////////////////////////////////////////////////////////////////////
function cellEnterKeyUpdateTotalBasket(cell){
	// update total
	updateTotalBasket();
	// Add keypress event to handle Enter key
	cell.on('keypress', function(event) {
		if (event.which === 13) { // Enter key
			event.preventDefault();
			$(this).blur(); // Remove focus and stop editing
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Clear exsiting enrolment 
//////////////////////////////////////////////////////////////////////////////////////////////////////
function removeAllInBasket(){
	// get id from 'formId'
	const studentId = $('#formId').val();
	// check if last invoice is full paid or not
	$.ajax({
		url: '${pageContext.request.contextPath}/invoice/last/' + studentId,
		method: 'GET',
		success: function(response) {
			// console.log(response);
			// Handle the response
			if(response === false){
				$('#warning-alert .modal-body').text('Last invoice is not fully paid');
				$('#warning-alert').modal('toggle');
				return;
			}else{
				// clean up enrolments in basket table
				clearEnrolmentBasket();
				// clean up invoice table
				clearInvoiceTable();
			}
		},
		error: function(xhr, status, error) {
			// Handle the error
			console.error(error);
		}
	});
}
</script>

	<style>
		.nav-tabs .nav-item.nav-link {
			border: 2.5px solid transparent; /* Set the initial border width and color */
			border-bottom-width: 0px; /* Increase the border width at the bottom */
			border-radius: 5; /* Optional: Remove border radius if you want */
		}
	
		.nav-tabs .nav-item.nav-link.active {
			border-color: #dee2e6; /* Change border color for active tab */
		}
	
		#basketTable th:nth-child(1) { width: 0%; } /* hidden id */
		#basketTable th:nth-child(2) { width: 5%; }  /* item */
		#basketTable th:nth-child(3) { width: 18%; } /* name */
		#basketTable th:nth-child(4) { width: 13%; } /* day */
		#basketTable th:nth-child(5) { width: 7%; } /* year */
		#basketTable th:nth-child(6) { width: 7%; } /* start */
		#basketTable th:nth-child(7) { width: 7%; } /* end */
		#basketTable th:nth-child(8) { width: 6%; } /* weeks */
		#basketTable th:nth-child(9) { width: 4%; } /* credit % */
		#basketTable th:nth-child(10) { width: 10%; } /* discount % */
		#basketTable th:nth-child(11) { width: 8%; } /* price */
		#basketTable th:nth-child(12) { width: 11%; } /* amount */
		#basketTable th:nth-child(13) { width: 4%; } /* delete */
	
		#basketTable td:nth-child(1) { width: 0%; } /* hidden id */
		#basketTable td:nth-child(2) { width: 5%; }  /* item */
		#basketTable td:nth-child(3) { width: 18%; } /* name */
		#basketTable td:nth-child(4) { width: 13%; } /* day */
		#basketTable td:nth-child(5) { width: 7%; } /* year */
		#basketTable td:nth-child(6) { width: 7%; } /* start */
		#basketTable td:nth-child(7) { width: 7%; } /* end */
		#basketTable td:nth-child(8) { width: 6%; } /* weeks */
		#basketTable td:nth-child(9) { width: 4%; } /* credit % */
		#basketTable td:nth-child(10) { width: 10%; } /* discount % */
		#basketTable td:nth-child(11) { width: 8%; } /* price */
		#basketTable td:nth-child(12) { width: 11%; } /* amount */
		#basketTable td:nth-child(13) { width: 4%; } /* delete */
	</style>
	
	<div class="modal-body" style="padding-left: 0px; padding-right: 5px;">
		<form id="courseRegister">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<select class="form-control form-control-sm" id="registerGrade" name="registerGrade">
							<option>Grade</option>
							<option value="1">P2</option>
							<option value="2">P3</option>
							<option value="3">P4</option>
							<option value="4">P5</option>
							<option value="5">P6</option>
							<option value="6">S7</option>
							<option value="7">S8</option>
							<option value="8">S9</option>
							<option value="9">S10</option>
							<option value="10">S10E</option>
							<option value="11">TT6</option>
							<option value="12">TT8</option>
							<option value="13">TT8E</option>
							<option value="14">SRW4</option>
							<option value="15">SRW5</option>
							<option value="16">SRW6</option>
							<option value="17">SRW7</option>
							<option value="18">SRW8</option>
							<option value="19">JMSS</option>
							<option value="20">VCE</option>
						</select>
					</div>
					<div class="offset-md-6">
					</div>
					<div class="col-md-2">
						<button id="applyEnrolmentBtn" type="button" class="btn btn-block btn-primary btn-sm" data-toggle="modal" onclick="associateRegistration()">Enrolment</button>
					</div>
					<div class="col-md-2">
						<button id="applyEnrolmentBtn" type="button" class="btn btn-block btn-info btn-sm" data-toggle="modal" onclick="removeAllInBasket()">Start New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<nav>
							<div class="nav nav-tabs nav-fill" id="nav-tab" role="tablist">
								<a class="nav-item nav-link active" id="nav-basket-tab" data-toggle="tab" href="#nav-basket" role="tab" aria-controls="nav-basket" aria-selected="true">Purchased Items</a>
								<a class="nav-item nav-link" id="nav-fee-tab" data-toggle="tab" href="#nav-fee" role="tab" aria-controls="nav-fee" aria-selected="true">Course To Choose</a>
								<a class="nav-item nav-link" id="nav-book-tab" data-toggle="tab" href="#nav-book" role="tab" aria-controls="nav-book" aria-selected="false">Books To Purchase</a>
							</div>
						</nav>                  
						<div class="tab-content" id="nav-tabContent">
						
						<!-- Purchased Items List -->
						<div class="tab-pane fade show active" id="nav-basket" role="tabpanel" aria-labelledby="nav-basket-tab">
							<table class="table" id="basketTable" name="basketTable">
								<thead>
									<tr class="d-flex">
										<th class="hidden-column"></th>
										<th class="smaller-table-font text-center" style="padding-left: 0.25rem;" data-toggle="tooltip" title="Type of Purchased Item">Item</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Name of Purchased Item">Name</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Class Schedule Day">Day</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Class Year">Year</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Class Start Week">Start</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Class End Week">End</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Class Total Weeks">Wks</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Credit">CR</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Discount">DC</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="Purchased Item Unit Price">Price</th>
										<th class="smaller-table-font text-center" data-toggle="tooltip" title="PUrchased Item Total Price">Amount</th>
										<th class="smaller-table-font text-center hidden-column"></th>
									</tr>
								</thead>
								<tbody>	
								</tbody>
								<tfoot>
									<tr>
										<th class="text-right pr-5">Total &nbsp;&nbsp;<span id="basketTotal" class="text-primary">0.00</span></td>
									</tr>
								</tfoot>
							</table> 
						</div>
						<!-- Course List -->
						<div class="tab-pane fade" id="nav-fee" role="tabpanel" aria-labelledby="nav-fee-tab">
							<table class="table" id="courseTable" name="courseTable">
								<thead>
									<tr class="d-flex">
										<th class="hidden-column"></th>
										<th class="smaller-table-font col-1">Item</th>
										<th class="smaller-table-font col-10" style="padding-left: 20px;">Name</th>
										<!-- <th class="smaller-table-font col-4" style="padding-left: 20px;">Subjects</th> -->
										<th class="smaller-table-font col-1"></th>
									</tr>
								</thead>
								<tbody>									
								</tbody>
							</table>
						</div>
						<!-- Book -->
						<div class="tab-pane fade" id="nav-book" role="tabpanel" aria-labelledby="nav-book-tab">
							<table class="table" cellspacing="0" id="bookTable" name="bookTable">
								<thead>
									<tr class="d-flex">
										<th class="hidden-column"></th>
										<th class="smaller-table-font col-1">Item</th>
										<th class="smaller-table-font col-5" style="padding-left: 20px;">Description</th>
										<th class="smaller-table-font col-4" style="padding-left: 20px;">Subjects</th>
										<th class="smaller-table-font col-1">Price</th>
										<th class="smaller-table-font col-1"></th>
									</tr>
								</thead>
								<tbody>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</form>
</div>
	
<!-- Bootstrap Alert (Hidden by default) -->
<div id="addAlert" class="alert alert-info alert-dismissible fade hide" role="alert" style="display: none;">
    This is an alert that pops up when the user clicks the 'OK' button.
</div>
<div id="warningAlert" class="alert alert-warning alert-dismissible fade hide" role="alert" style="display: none;">
    This is an alert that pops up when the user clicks the 'OK' button.
</div>
<div id="deleteAlert" class="alert alert-danger alert-dismissible fade hide" role="alert" style="display: none;">
    This is an alert that pops up when the user clicks the 'OK' button.
</div>

<!-- Bootstrap Editable Table JavaScript -->
<script src="${pageContext.request.contextPath}/js/bootstrap-table-1.21.4.min.js"></script>
		
			
	