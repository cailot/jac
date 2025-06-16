<script>

const ACADEMIC_NEXT_YEAR_COURSE_SUFFIX = " (Next Year)";
var academicYear;
var academicWeek;
var lastAcademicWeek;

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
				// get last academic week
				$.ajax({
					url: '${pageContext.request.contextPath}/class/lastAcademicWeek',
					type: 'GET',
					data: { year: academicYear },
					success: function(response) {	
						lastAcademicWeek = response;
					},
					error: function(jqXHR, textStatus, errorThrown) {
						console.log('Error : ' + errorThrown);
					}
				});

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
			// if it is 'book', simply remove <tr>, if it is 'class', remove this row and its paired online/onsite class
			var hiddens = tr.find('.data-type').text();
			if(hiddens.indexOf('|') !== -1){
				var hiddenValues = hiddens.split('|');
				if(hiddenValues[0] === BOOK){
					// delete only the current book row
					tr.remove();
				}else if(hiddenValues[0] === CLASS){
					// Get identifying information from the current row
					var pairId = tr.data('pair-id');
					var year = tr.find('.year').text();
					var name = tr.find('.name').text();
					var isOnline = tr.find('.online').text() === "true";
					
					if (isOnline) {
						// If this is an online class, find and remove the corresponding onsite class with same name/year
						var baseName = name.replace(/\s+Online$/, '').trim();
						var $onsiteRow = $('#basketTable > tbody > tr').filter(function() {
							var rowName = $(this).find('.name').text().trim();
							var rowIsOnline = $(this).find('.online').text() === "true";
							var rowYear = $(this).find('.year').text();
							
							return !rowIsOnline && 
								   rowYear === year && 
								   (rowName === baseName || rowName === baseName + " Onsite");
						});
						$onsiteRow.remove();
						tr.remove();
					} else {
						// If this is an onsite class, find and remove any paired online class
						// First, clean up the name to get the base class name
						var baseName = name.replace(/\s+Onsite$/, '').trim();
						
						// Look for online classes with the same year and matching name pattern
						var $onlineRows = $('#basketTable > tbody > tr').filter(function() {
							var rowName = $(this).find('.name').text().trim();
							var rowIsOnline = $(this).find('.online').text() === "true";
							var rowYear = $(this).find('.year').text();
							
							// Match any online class with same year and either:
							// 1. Same exact base name + " Online" suffix
							// 2. Same base name (if it already has "Online" in the name)
							return rowIsOnline && 
								   rowYear === year && 
								   (rowName === baseName + " Online" || 
								    rowName === baseName);
						});
						
						$onlineRows.remove();
						tr.remove();
					}
				}
			}
			updateTotalBasket();
			showAlertMessage('deleteAlert', '<center><i class="bi bi-trash"></i> &nbsp;&nbsp Item is now removed from Purchased Items</center>');
		});

		// Add event listeners to the input fields within the same row
		$('#basketTable').on('input', '.onsiteStart, .onsiteEnd, .onsiteWeeks, .onsiteCredit', function () {
			var $onsiteRow = $(this).closest('tr');  // Find the closest onsite row
			var pairId = $onsiteRow.data('pair-id');  // Get the pair ID
			var onsiteYear = $onsiteRow.find('.year').text(); // Get the year of the onsite row
			
			// Find the corresponding online row with the same pairId AND year
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').not($onsiteRow).filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			
			if ($onlineRow.length) {
				syncValues($onsiteRow, $onlineRow);  // Pass both rows to the syncValues function
				calculateAmount($onsiteRow);  // Update amount for onsite class
			}
		});

	}
);


//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Sync values between onsite and online rows    
//////////////////////////////////////////////////////////////////////////////////////////////////////
function syncValues($onsiteRow, $onlineRow) {
    // Parse integer values from the onsite start and end dates within the same row
    var onsiteStartValue = parseInt($onsiteRow.find('.start-week').text(), 10) || 0;
    $onlineRow.find('.start-week').text(onsiteStartValue);

    var onsiteEndValue = parseInt($onsiteRow.find('.end-week').text(), 10) || 0;
    $onlineRow.find('.end-week').text(onsiteEndValue);

    var onsiteWeeksValue = parseInt($onsiteRow.find('.weeks').text(), 10) || 0;
    $onlineRow.find('.weeks').text(onsiteWeeksValue);

    var onsiteCreditValue = parseInt($onsiteRow.find('.credit').text(), 10) || 0;
    $onlineRow.find('.credit').text(onsiteCreditValue);

    // Ensure online class maintains 100% discount
    $onlineRow.find('.discount').text('100%');
    
    // Update amount for online class (should be 0 due to 100% discount)
    calculateAmount($onlineRow);
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
	  branch : isOnline ? 90 : branch	
	},
	success: function(data) {
		var start_week, end_week;        
		if (value.year == academicYear) {
			start_week = parseInt(academicWeek);
			end_week = parseInt(academicWeek) + 9;	
			if (end_week >= lastAcademicWeek) {
				end_week = lastAcademicWeek;
			}
		} else {
			start_week = 1;
			end_week = 10;
		}    
		var row = $('<tr class="d-flex" data-pair-id="' + gradePair + '">');
		row.append($('<td>').addClass('hidden-column data-type').text(CLASS +'|' + (data[0] ? data[0].id : '')));
		row.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>')); // item
		row.append($('<td class="smaller-table-font name">').text(value.name)); // name
		
		// For day field - create dropdown for onsite classes, static text for online classes
		if (isOnline) {
			// Online classes show static "All"
			row.append($('<td class="smaller-table-font day">').text('All')); // day
		} else {
			// Create dropdown for onsite classes
			var dayDropdown = $('<select class="clazzChoice">').css({
				'width': '85px',
				'font-size': '12px',
				'padding': '2px'
			});
			
			// Add options from the data
			$.each(data, function(index, clazz) {
				var option = $('<option>').text(dayName(clazz.day)).val(clazz.id).data('price', clazz.price);
				if (index === 0) {
					option.prop('selected', true);
				}
				dayDropdown.append(option);
			});

			// Add change handler
			dayDropdown.on('change', function() {
				var selectedValue = $(this).val();
				var selectedPrice = $(this).find('option:selected').data('price');
				var currentRow = $(this).closest('tr');
				
				// Update the hidden data-type field
				currentRow.find('.data-type').text(CLASS + '|' + selectedValue);
				// Update price
				currentRow.find('.price').text(Number(selectedPrice).toFixed(2));
				// Recalculate amount
				var weeksTotal = parseInt(currentRow.find('.weeks').text()) || 0;
				var credit = parseInt(currentRow.find('.credit').text()) || 0;
				var discount = currentRow.find('.discount').text() || '0';
				var totalPrice = Math.max(0, (weeksTotal - credit) * selectedPrice);
				
				if (discount.toString().includes('%')) {
					var discountPercent = parseFloat(discount.replace('%', '')) || 0;
					totalPrice = totalPrice - (totalPrice * (discountPercent / 100));
				} else {
					var discountAmount = parseFloat(discount) || 0;
					totalPrice = Math.max(0, totalPrice - discountAmount);
				}
				
				currentRow.find('.amount').text(totalPrice.toFixed(2));
				updateTotalBasket();
			});
			
			row.append($('<td class="smaller-table-font day">').append(dayDropdown)); // day with dropdown
		}
		
		row.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year
		row.append($('<td class="smaller-table-font text-center start-week onsiteStart" contenteditable="true">').text(start_week).on('input', function() {
			var row = $(this).closest('tr');
			var startWeek = parseInt($(this).text()) || 0;
			var endWeek = parseInt(row.find('.end-week').text()) || 0;
			var weeks = endWeek - startWeek + 1;
			row.find('.weeks').text(weeks);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			calculateAmount(row);
		}));

		row.append($('<td class="smaller-table-font text-center end-week onsiteEnd" contenteditable="true">').text(end_week).on('input', function() {
			var row = $(this).closest('tr');
			var startWeek = parseInt(row.find('.start-week').text()) || 0;
			var endWeek = parseInt($(this).text()) || 0;
			var weeks = endWeek - startWeek + 1;
			row.find('.weeks').text(weeks);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			calculateAmount(row);
		}));

		row.append($('<td class="smaller-table-font text-center weeks onsiteWeeks" contenteditable="true">').text((end_week - start_week) + 1).on('input', function() {
			var row = $(this).closest('tr');
			var startWeek = parseInt(row.find('.start-week').text()) || 0;
			var weeks = parseInt($(this).text()) || 0;
			var endWeek = startWeek + weeks - 1;
			row.find('.end-week').text(endWeek);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			calculateAmount(row);
		}));

		row.append($('<td class="smaller-table-font text-center credit onsiteCredit" contenteditable="true">').text(0).on('input', function() {
			var row = $(this).closest('tr');
			var creditValue = parseInt($(this).text()) || 0;
			var startWeek = parseInt(row.find('.start-week').text()) || 0;
			var currentEndWeek = parseInt(row.find('.end-week').text()) || 0;
			var currentWeeks = parseInt(row.find('.weeks').text()) || 0;
			
			// Update the end week based on credit value
			var newEndWeek = startWeek + currentWeeks - 1 + creditValue;
			row.find('.end-week').text(newEndWeek);
			
			// Update the total weeks value
			var newWeeks = currentWeeks + creditValue;
			row.find('.weeks').text(newWeeks);
			
			// Update amount - only charge for non-credited weeks
			var price = parseFloat(row.find('.price').text()) || 0;
			var discount = row.find('.discount').text() || '0';
			// Original weeks before adding credit - only charge for these
			var originalWeeks = currentWeeks;
			var amount = originalWeeks * price;
			
			if (discount.includes('%')) {
				amount *= (1 - (parseFloat(discount) || 0) / 100);
			} else {
				var discountAmount = parseFloat(discount) || 0;
				amount = Math.max(0, amount - discountAmount);
			}
			
			row.find('.amount').text(amount.toFixed(2));
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			updateTotalBasket();
		}));

		row.append($('<td class="smaller-table-font text-center discount" contenteditable="true">').text(0).on('input', function() {
			calculateAmount($(this).closest('tr'));
		}));

		var initialPrice = data[0] ? data[0].price : 0;
		row.append($('<td class="smaller-table-font text-center price">').text(Number(initialPrice).toFixed(2)));
		row.append($('<td class="smaller-table-font text-center amount">').text(((end_week - start_week + 1) * initialPrice).toFixed(2)));
		
		row.append($('<td>').html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete class"><i class="bi bi-trash"></i></a>')); // delete
		row.append($('<td class="hidden-column enrolId">').text('')); // enrolId
		row.append($('<td class="hidden-column invoiceId">').text('')); // invoiceId
		row.append($('<td class="hidden-column online">').text(isOnline)); // online
		row.append($('<td class="hidden-column grade">').text(value.grade)); // grade
		row.append($('<td class="hidden-column description">').text(value.description)); // description

		$('#basketTable > tbody').prepend(row);
		
		// Handle online class if needed
		if (!isOnline) {
			var clazzId = 0;
			var isNewClazz = (value.description.indexOf(ACADEMIC_NEXT_YEAR_COURSE_SUFFIX) !== -1);
			$.ajax({
				url: '${pageContext.request.contextPath}/class/onlineId',
				type: 'GET',
				data: {
					grade: grade,
					year: year
				},
				success: function(data) {
					if ((data !== '') && (data > 0)) {
						clazzId = data;
						$('#courseTable > tbody > tr').each(function() {
							var title = $(this).find('.course-title').text();
							if (title.toUpperCase().indexOf(ONLINE) !== -1) {
								var isNewOnlineClazz = (title.indexOf(ACADEMIC_NEXT_YEAR_COURSE_SUFFIX) !== -1);
								if (isNewClazz == isNewOnlineClazz) {
									var clazzName = '';
									var clazzDescription = '';
									if (title.indexOf('-') !== -1) {
										clazzName = title.split('-')[0].trim();
										clazzDescription = title.split('-')[1].trim();
									}
									
									var onlineRow = $('<tr class="d-flex" data-pair-id="' + gradePair + '">');
									onlineRow.append($('<td>').addClass('hidden-column data-type').text(CLASS + '|' + clazzId));
									onlineRow.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>')); // item
									onlineRow.append($('<td class="smaller-table-font name">').text(clazzName)); // name
									onlineRow.append($('<td class="smaller-table-font day">').text('All')); // day
									onlineRow.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year
									onlineRow.append($('<td class="smaller-table-font text-center start-week onlineStart">').text(start_week));
									onlineRow.append($('<td class="smaller-table-font text-center end-week onlineEnd">').text(end_week));
									onlineRow.append($('<td class="smaller-table-font text-center weeks onlineWeeks">').text((end_week - start_week) + 1));
									onlineRow.append($('<td class="smaller-table-font text-center credit onlineCredit">').text(0));
									onlineRow.append($('<td class="smaller-table-font text-center discount">').text('100%'));
									onlineRow.append($('<td class="smaller-table-font text-center price">').text(0)); // price
									onlineRow.append($('<td class="smaller-table-font text-center amount">').text(0)); // amount					
									onlineRow.append($('<td>'));
									onlineRow.append($('<td class="hidden-column enrolId">').text('')); // enrolId
									onlineRow.append($('<td class="hidden-column invoiceId">').text('')); // invoiceId
									onlineRow.append($('<td class="hidden-column online">').text(true)); // online				
									onlineRow.append($('<td class="hidden-column grade">').text(value.grade)); // grade
									onlineRow.append($('<td class="hidden-column description">').text(clazzDescription)); // description
									
									$('#basketTable > tbody').append(onlineRow);
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
		showAlertMessage('addAlert', '<center><i class="bi bi-mortarboard"></i> &nbsp;&nbsp' + value.description + ' added to Purchased Items</center>');
	},
	error: function(xhr, status, error) {
		console.log('Error : ' + error);
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
        showAlertMessage('warningAlert', '<center><i class="bi bi-book"></i> &nbsp;&nbsp' + value.name +' is already in Purchased Items</center>');
        return;
    }
    var row = $('<tr class="d-flex">');
    row.append($('<td>').addClass('hidden-column').addClass('data-type').text(BOOK + '|' + value.id)); // 0
    row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>')); // item
    row.append($('<td class="smaller-table-font name" style="width: 43%;">').text(value.name)); // name - increased width from 36% to 43%
    // Skip one column since we're extending the name column
    row.append($('<td style="width: 6%;">'));
    row.append($('<td style="width: 6%;">'));
    row.append($('<td style="width: 6%;">'));
    row.append($('<td style="width: 4%;">'));
    row.append($('<td style="width: 7%;">'));
    row.append($('<td style="width: 8%;">')); // price
    
    if (value.name === 'Extra') {
        var cell = $('<td class="smaller-table-font text-center amount" contenteditable="true">').text('0');
        
        cell.on('keydown', function(event) {
            // Allow backspace and delete
            if (event.keyCode === 8 || event.keyCode === 46) {
                return true;
            }
        }).on('keypress', function(event) {
            var charCode = (event.which) ? event.which : event.keyCode;
            
            // Handle Enter key
            if (charCode === 13) {
                event.preventDefault();
                $(this).blur();
                return false;
            }
            
            // Only allow numbers and decimal point
            if (charCode !== 46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
                event.preventDefault();
                return false;
            }
            
            // Prevent multiple decimal points
            if (charCode === 46 && $(this).text().indexOf('.') !== -1) {
                event.preventDefault();
                return false;
            }
        }).on('input', function() {
            var value = $(this).text().trim();
            // Allow empty or valid number
            if (value === '' || (!isNaN(value) && value.match(/^\d*\.?\d*$/))) {
                updateTotalBasket();
            } else {
                $(this).text('0');
                updateTotalBasket();
            }
        }).on('blur', function() {
            var value = $(this).text().trim();
            if (value === '' || isNaN(value)) {
                $(this).text('0');
            }
            updateTotalBasket();
        });
        
        row.append(cell);
    } else {
        row.append($('<td class="smaller-table-font text-center price amount">').text(Number(value.price).toFixed(2)));
    }
    
    row.append($('<td style="width: 4%;">').html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete book"><i class="bi bi-trash"></i></a>')); // Action
    row.append($('<td>').addClass('hidden-column').addClass('grade').text(value.grade)); 
    row.append($('<td>').addClass('hidden-column').addClass('materialId').text('')); 
    row.append($('<td>').addClass('hidden-column').addClass('invoiceId').text('')); 
        
    $('#basketTable > tbody').append(row);

    // update total    
    updateTotalBasket();
    
    // Automatically dismiss the alert after 2 seconds
    showAlertMessage('addAlert', '<center><i class="bi bi-book"></i> &nbsp;&nbsp' + value.name +' added to Purchased Items</center>');
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

	var enrolData = [];
	var bookData = [];

	$('#basketTable tbody tr').each(function() {
		// in case of update, enrolId is not null
		var clazzId = null;
		var bookId = null;
		var hiddens = $(this).find('.data-type').text();
		if(hiddens.indexOf('|') !== -1){
			var hiddenValues = hiddens.split('|');
			if(hiddenValues[0] === BOOK){
				bookId = hiddenValues[1];
				var materialId = $(this).find('.materialId').text();
				var invoiceId = $(this).find('.invoiceId').text();
				var name = $(this).find('.name').text();
				var amount = name === 'Extra' ? parseFloat($(this).find('.amount').text()) || 0 : parseFloat($(this).find('.price').text()) || 0;
				var book = {
					"id" : materialId,
					"invoiceId" : invoiceId,
					"bookId" : bookId,
					"price" : amount,
					"name": name
				};
				bookData.push(book);
			}else if(hiddenValues[0] === CLASS){
				clazzId = hiddenValues[1];
				var enrol = {
					"id": $(this).find('.enrolId').text(),
					"startWeek": parseInt($(this).find('.start-week').text()) || 0,
					"endWeek": parseInt($(this).find('.end-week').text()) || 0,
					"price": parseFloat($(this).find('.price').text()) || 0,
					"grade": $(this).find('.grade').text(),
					"year": $(this).find('.year').text(),
					"name": $(this).find('.name').text(),
					"invoiceId": $(this).find('.invoiceId').text(),
					"amount": parseFloat($(this).find('.amount').text()) || 0,
					"discount": $(this).find('.discount').text() || '0',
					"credit": parseInt($(this).find('.credit').text()) || 0,
					"weeks": parseInt($(this).find('.weeks').text()) || 0,
					"online": $(this).find('.online').text() === 'true',
					"paid": $(this).find('.paid').text(),
					"extra": $(this).find('.extra').text(),
					"day": $(this).find('.clazzChoice option:selected').text() || $(this).find('.day').text(),
					"clazzId": clazzId,
					"studentId": studentId
				};
				enrolData.push(enrol);
			}
		}
	});

	// Promise ajax call
	function associateClazz(studentId) {
		return new Promise((resolve, reject) => {
			// Create a combined data object that includes both enrolment and book data
			var combinedData = {
				enrolments: enrolData,
				materials: bookData  // Use the bookData from the parent scope
			};
			
			$.ajax({
				url: '${pageContext.request.contextPath}/enrolment/associateClazz/' + studentId,
				method: 'POST',
				data: JSON.stringify(combinedData),
				contentType: 'application/json',
				success: function(response) {
					resolve(response);
				},
				error: function(xhr, status, error) {
					console.error('Error in associateClazz:', error);
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
					resolve(response);
				},
				error: function(xhr, status, error) {
					console.error('Error in associateBook:', error);
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
					resolve(response);
				},
				error: function(xhr, status, error) {
					console.error('Error in associatePayment:', error);
					reject(error);
				}
			});
		});
	}

	// call one by one : associateClazz -> associateBook -> associatePayment
	associateClazz(studentId, enrolData)
		.then((clazzResponse) => {
			return associateBook(studentId, bookData);
		})
		.then((bookResponse) => {
			return associatePayment(studentId);
		})
		.then((paymentResponse) => {
			// Clear tables and update display
			clearInvoiceTable();
			clearEnrolmentBasket();
			retrieveEnrolment(studentId);
			
			// Add a longer delay and better function availability check
			setTimeout(function() {
				if (typeof window.retrieveAttendance === 'function') {
					window.retrieveAttendance(studentId);
				} else if (typeof retrieveAttendance === 'function') {
					retrieveAttendance(studentId);
				} else {
					console.error('retrieveAttendance function not found!');
				}
			}, 1000); // Increased delay to 1 second
		})
		.catch(error => {
			console.error('Association error:', error);
			$('#warning-alert .modal-body').text('Error during registration: ' + error);
			$('#warning-alert').modal('toggle');
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
						$.each(value, function(count, data) {
							if (index == 0) {
								updateInvoiceTableWithTop(data, index);
							} else {
								updateInvoiceTableWithRest(data, index);
							}
						});
					} // end of for loop

					// After all rows are added, set up event handlers for synchronization
					$('#basketTable tr').each(function() {
						var $row = $(this);
						if ($row.find('.online').text() !== "true") {  // Only for onsite classes
							$row.find('.start-week, .end-week, .weeks, .credit').on('input', function() {
								var pairId = $row.data('pair-id');
								var year = $row.find('.year').text();
								var $onlineRow = $('#basketTable tr').filter(function() {
									return $(this).data('pair-id') === pairId && 
										   $(this).find('.year').text() === year && 
										   $(this).find('.online').text() === "true";
								});
								
								if ($onlineRow.length) {
									// Sync values
									$onlineRow.find('.start-week').text($row.find('.start-week').text());
									$onlineRow.find('.end-week').text($row.find('.end-week').text());
									$onlineRow.find('.weeks').text($row.find('.weeks').text());
									$onlineRow.find('.credit').text($row.find('.credit').text());
									$onlineRow.find('.discount').text('100%');
									
									// Update calculations
									calculateAmount($row);
									calculateAmount($onlineRow);
								}
							});
						}
					});
					
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
	.then(() => {
		// After enrollment and balance are loaded, retrieve attendance
					setTimeout(function() {
			if (typeof window.retrieveAttendance === 'function') {
				window.retrieveAttendance(studentId);
			} else if (typeof retrieveAttendance === 'function') {
				retrieveAttendance(studentId);
			} else {
				console.error('retrieveAttendance function not available yet');
			}
		}, 500);
	})
	.catch(error => {
		console.error('Error:', error);
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//	Update Invoice Table with lastest EnrolmentDTO
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInvoiceTableWithTop(value, rowCount) {

	// Add validation to prevent invalid/empty data from being displayed
	if (!value || typeof value !== 'object') {
		return;
	}

	if (value.hasOwnProperty('bookId')) { // It is an MaterialDTO object - check this first since books now also have 'extra' field

		// Validate book data
		if (!value.name || value.price == null || isNaN(value.price)) {
			return;
		}

		// update my lecture table
		var row = $('<tr class="d-flex">');
		row.append($('<td>').addClass('hidden-column').addClass('data-type').text(BOOK + '|' + value.bookId)); // 0
		// Check payment status and apply appropriate styling to book icon
		if (value.extra === OVERDUE) {
			row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book text-danger" data-toggle="tooltip" title="Overdue"></i></td>')); // item
		} else {
			row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>')); // item
		}
		row.append($('<td class="smaller-table-font" style="width: 43%;">').text(value.name)); // name - increased width from 36% to 43%
		// Skip one column since we're extending the name column  
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 4%;">'));
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 8%;">')); // price
		
		// For Extra material, use the saved extra amount, otherwise use the book's price
		var displayPrice = value.name === 'Extra' ? parseFloat(value.input) || value.price : value.price;
		row.append($('<td class="smaller-table-font text-center price amount" style="width: 11%;">').text(displayPrice.toFixed(2)));

		row.append($("<td style='width: 4%;'>").html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete book"><i class="bi bi-trash"></i></a>')); // Action
		row.append($('<td class="hidden-column grade">').text(value.grade));
		row.append($('<td class="hidden-column materialId">').text(value.id)); 
		row.append($('<td class="hidden-column invoiceId">').text(value.invoiceId)); 

		$('#basketTable > tbody').append(row);
		// update invoice table with Book
		addBookToInvoiceList(value, rowCount);

	}else if (value.hasOwnProperty('method')) { // It is an PaymentDTO object - check this BEFORE extra property
		// Validate payment data
		if (!value.method || value.amount == null || isNaN(value.amount)) {
			return;
		}
		
		// update invoice table with Payment
		addPaymentToInvoiceList(value, rowCount);
		
	}else if (value.hasOwnProperty('extra')) { // It is an EnrolmentDTO object

		// Validate enrollment data to prevent NaN entries
		if (!value || typeof value !== 'object') {
			return;
		}

		// Set default values for missing or invalid data
		value.name = value.name || '';
		value.startWeek = parseInt(value.startWeek) || 0;
		value.endWeek = parseInt(value.endWeek) || 0;
		value.price = parseFloat(value.price) || 0;
		value.credit = parseInt(value.credit) || 0;
		value.discount = value.discount || '0';
		value.clazzId = value.clazzId || '';
		value.year = value.year || '';
		value.online = !!value.online;

		let freeOnline = value.online && value.discount === DISCOUNT_FREE;
		
		// Add ALL enrollments to basket table (Purchased Items section) - including free online classes
		var row = $('<tr class="d-flex">');
		row.append($('<td>').addClass('hidden-column data-type').text(CLASS + '|' + (value.clazzId || '')));
		
		// Check payment status and apply appropriate styling to class icon
		if (value.extra === OVERDUE) {
			row.append($('<td class="text-center"><i class="bi bi-mortarboard text-danger" data-toggle="tooltip" title="Overdue"></i></td>')); // item
		} else {
			row.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>')); // item
		}
		
		row.append($('<td class="smaller-table-font name">').text(value.name || '')); // name
		
		// For day field - create dropdown for onsite classes, static text for online classes
		if (value.online) {
			// Online classes show static "All"
			row.append($('<td class="smaller-table-font day">').text('All')); // day
		} else {
			// Onsite classes get a dropdown - create new dropdown for existing enrollments
			var dayDropdown = $('<select class="clazzChoice">').css({
				'width': '85px',
				'font-size': '12px',
				'padding': '2px'
			});
			
			// Add the current selection as the initial option
			var currentDayOption = $('<option>').text(dayName(value.day) || '').val(value.clazzId || '').data('price', value.price || 0);
			dayDropdown.append(currentDayOption);
			
			// Load all available classes for this course using the current clazzId
			var clazzId = value.clazzId || '';
			var year = value.year || '';
			var state = $('#formState').val() || '';
			var branch = $('#formBranch').val() || '';
			
			if (clazzId && year) {
				$.ajax({
					url: '${pageContext.request.contextPath}/class/associatedClass',
					type: 'GET',
					data: {
						clazzId: clazzId,
						year: year,
						state: state,
						branch: branch
					},
					success: function(data) {
						// Clear existing options
						dayDropdown.empty();
						// Add all available classes
						$.each(data, function(index, clazz) {
							var option = $('<option>').text(dayName(clazz.day)).val(clazz.id).data('price', clazz.price);
							// Mark current selection as selected
							if (clazz.id == (value.clazzId || '')) {
								option.prop('selected', true);
							}
							dayDropdown.append(option);
						});
					},
					error: function(xhr, status, error) {
						console.error('Error loading classes for existing enrollment:', error);
						// Fallback to current selection only
						dayDropdown.empty();
						dayDropdown.append(currentDayOption);
					}
				});
			}
			
			// Add change handler for existing enrollments
			dayDropdown.on('change', function() {
				var selectedValue = $(this).val();
				var selectedPrice = $(this).find('option:selected').data('price') || 0;
				var currentRow = $(this).closest('tr');
				
				// Update the hidden data-type field with new class ID
				currentRow.find('.data-type').text(CLASS + '|' + selectedValue);
				// Update price
				currentRow.find('.price').text(Number(selectedPrice).toFixed(2));
				// Recalculate amount
				var weeksTotal = parseInt(currentRow.find('.weeks').text()) || 0;
				var credit = parseInt(currentRow.find('.credit').text()) || 0;
				var discount = currentRow.find('.discount').text() || '0';
				var totalPrice = Math.max(0, (weeksTotal - credit) * selectedPrice);
				
				if (discount.toString().includes('%')) {
					var discountPercent = parseFloat(discount.replace('%', '')) || 0;
					totalPrice = totalPrice - (totalPrice * (discountPercent / 100));
				} else {
					var discountAmount = parseFloat(discount) || 0;
					totalPrice = Math.max(0, totalPrice - discountAmount);
				}
				
				currentRow.find('.amount').text(totalPrice.toFixed(2));
				updateTotalBasket();
			});
			
			row.append($('<td class="smaller-table-font day">').append(dayDropdown)); // day with dropdown
		}
		
		row.append($('<td class="smaller-table-font text-center year">').text(value.year || '')); // year
		row.append($('<td class="smaller-table-font text-center start-week onsiteStart" contenteditable="true">').text(value.startWeek || 0).on('input', function() {
			var row = $(this).closest('tr');
			var startWeek = parseInt($(this).text()) || 0;
			var endWeek = parseInt(row.find('.end-week').text()) || 0;
			var weeks = endWeek - startWeek + 1;
			row.find('.weeks').text(weeks);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			calculateAmount(row);
		}));

		row.append($('<td class="smaller-table-font text-center end-week onsiteEnd" contenteditable="true">').text(value.endWeek || 0).on('input', function() {
			var row = $(this).closest('tr');
			var startWeek = parseInt(row.find('.start-week').text()) || 0;
			var endWeek = parseInt($(this).text()) || 0;
			var weeks = endWeek - startWeek + 1;
			row.find('.weeks').text(weeks);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			calculateAmount(row);
		}));
		
		var weeksTotal = Math.max(0, (value.endWeek || 0) - (value.startWeek || 0) + 1);
		row.append($('<td class="smaller-table-font text-center weeks onsiteWeeks" contenteditable="true">').text(weeksTotal).on('input', function() {
			var row = $(this).closest('tr');
			var startWeek = parseInt(row.find('.start-week').text()) || 0;
			var weeks = parseInt($(this).text()) || 0;
			var endWeek = startWeek + weeks - 1;
			row.find('.end-week').text(endWeek);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var onsiteYear = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === onsiteYear && $(this).find('.online').text() === "true";
			});
			if ($onlineRow.length) {
				syncValues(row, $onlineRow);
			}
			
			calculateAmount(row);
		}));

		row.append($('<td class="smaller-table-font text-center credit onsiteCredit" contenteditable="true">').text(value.credit || 0).on('input', function() {
			var row = $(this).closest('tr');
			var creditValue = parseInt($(this).text()) || 0;
			var startWeek = parseInt(row.find('.start-week').text()) || 0;
			var currentWeeks = parseInt(row.find('.weeks').text()) || 0;
			
			// Update the end week based on credit value
			var newEndWeek = startWeek + currentWeeks - 1 + creditValue;
			row.find('.end-week').text(newEndWeek);
			
			// Update the total weeks value
			var newWeeks = currentWeeks + creditValue;
			row.find('.weeks').text(newWeeks);
			
			// Find and sync with online class
			var pairId = row.data('pair-id');
			var year = row.find('.year').text();
			var $onlineRow = $('#basketTable').find('tr[data-pair-id="' + pairId + '"]').filter(function() {
				return $(this).find('.year').text() === year && 
					   $(this).find('.online').text() === "true";
			});
			
			if ($onlineRow.length) {
				$onlineRow.find('.credit').text(creditValue);
				$onlineRow.find('.end-week').text(newEndWeek);
				$onlineRow.find('.weeks').text(newWeeks);
			}
			
			// Update amount - only charge for non-credited weeks
			var price = parseFloat(row.find('.price').text()) || 0;
			var discount = row.find('.discount').text() || '0';
			// Original weeks before adding credit - only charge for these
			var originalWeeks = currentWeeks;
			var amount = originalWeeks * price;
			
			if (discount.includes('%')) {
				amount *= (1 - (parseFloat(discount) || 0) / 100);
			} else {
				var discountAmount = parseFloat(discount) || 0;
				amount = Math.max(0, amount - discountAmount);
			}
			
			row.find('.amount').text(amount.toFixed(2));
			updateTotalBasket();
		}));

		row.append($('<td class="smaller-table-font text-center discount" contenteditable="true">').text(value.discount || '0').on('input', function() {
			calculateAmount($(this).closest('tr'));
		}));
		
		row.append($('<td class="smaller-table-font text-center price">').text(Number(value.price || 0).toFixed(2)));
		
		// Calculate amount
		calculateAmount(row);

		if(!freeOnline){
			// Calculate initial amount for class (both onsite and online)
			var weeks = parseInt(value.endWeek - value.startWeek + 1) || 0;
			var credit = parseInt(value.credit) || 0;
			var price = parseFloat(value.price) || 0;
			var discount = value.discount || '0';
			var chargeableWeeks = weeks - credit;
			var amount = chargeableWeeks * price;
			
			// Only set amount to 0 if discount is 100%
			if (discount === '100%') {
				amount = 0;
			} else if (discount.includes('%')) {
				var discountPercent = parseFloat(discount.replace('%', '')) || 0;
				amount *= (1 - (discountPercent / 100));
			} else {
				var discountAmount = parseFloat(discount) || 0;
				amount = Math.max(0, amount - discountAmount);
			}
			
			row.append($('<td class="smaller-table-font text-center amount">').text(amount.toFixed(2)));
		} else {
			row.append($('<td class="smaller-table-font text-center amount">').text('0.00'));
		}

		row.append($('<td>').html('<a href="javascript:void(0)" data-toggle="tooltip" title="Delete class"><i class="bi bi-trash"></i></a>')); // delete
		row.append($('<td class="hidden-column enrolId">').text(value.id || '')); // enrolId
		row.append($('<td class="hidden-column invoiceId">').text(value.invoiceId || '')); // invoiceId
		row.append($('<td class="hidden-column online">').text(value.online || false)); // online
		row.append($('<td class="hidden-column grade">').text(value.grade || '')); // grade
		row.append($('<td class="hidden-column description">').text(value.description || '')); // description

		$('#basketTable > tbody').append(row);

		// Only add to invoice table if NOT free online class
		if(!freeOnline){
			addEnrolmentToInvoiceList(value, rowCount);
		}
	} else {
		console.log('Object type not recognized in Rest. Properties:', Object.keys(value));
	}

	// update basket total
	updateTotalBasket();

}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//	Update Invoice Table with 2nd/3rd last EnrolmentDTO
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInvoiceTableWithRest(value, rowCount){

	// Add validation to prevent invalid/empty data from being displayed
	if (!value || typeof value !== 'object') {
		return;
	}

	if (value.hasOwnProperty('bookId')) { // It is an MaterialDTO object - check this first since books now also have 'extra' field

		// Validate book data
		if (!value.name || value.price == null || isNaN(value.price)) {
			return;
		}

		// update invoice table with Book
		addBookToInvoiceList(value, rowCount);

	}else if (value.hasOwnProperty('method')) { // It is an PaymentDTO object - check this BEFORE extra property
		// Validate payment data
		if (!value.method || value.amount == null || isNaN(value.amount)) {
			return;
		}
		
		// update invoice table with Payment
		addPaymentToInvoiceList(value, rowCount);
		
	}else if (value.hasOwnProperty('extra')) { // It is an EnrolmentDTO object

		// Validate enrollment data to prevent NaN entries
		if (!value.name || value.startWeek == null || value.endWeek == null || 
			value.price == null || isNaN(value.price) || 
			isNaN(value.startWeek) || isNaN(value.endWeek)) {
			return;
		}

		let freeOnline = value.online && value.discount === DISCOUNT_FREE;	
		// update invoice table with Enrolment unless free online class
		if(!freeOnline){
			addEnrolmentToInvoiceList(value, rowCount);
		}
	} else {
		console.log('Object type not recognized in Rest. Properties:', Object.keys(value));
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
				isExist = true;
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
			}
		},
		error: function(xhr, status, error) {
			// Handle the error
			console.error(error);
		}
	});
}

// Add this function to handle Extra amount editing
function handleExtraAmount(cell) {
    cell.on('input', function(e) {
        // Get cursor position before updating
        var cursorPos = getCaretPosition(this);
        
        // Get the raw input value
        var rawValue = $(this).text();
        
        // Remove any non-numeric characters except decimal point
        var numericValue = rawValue.replace(/[^\d.]/g, '');
        
        // Ensure only one decimal point
        var parts = numericValue.split('.');
        if (parts.length > 2) {
            numericValue = parts[0] + '.' + parts.slice(1).join('');
        }
        
        // Parse the value and format to 2 decimal places
        var amount = parseFloat(numericValue) || 0;
        var formattedValue = amount.toFixed(2);
        
        // Only update if the value has changed
        if ($(this).text() !== formattedValue) {
            $(this).text(formattedValue);
            // Restore cursor position
            setCaretPosition(this, cursorPos);
        }
        
        updateTotalBasket();
    }).on('keypress', function(event) {
        // Allow only numbers, decimal point, and control keys
        var charCode = (event.which) ? event.which : event.keyCode;
        if (charCode === 13) { // Enter key
            event.preventDefault();
            $(this).blur();
            return false;
        }
        if (charCode !== 46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
            return false;
        }
    });
}

// Helper function to get caret position
function getCaretPosition(element) {
    var caretPos = 0;
    if (window.getSelection) {
        var selection = window.getSelection();
        if (selection.rangeCount) {
            var range = selection.getRangeAt(0);
            var preCaretRange = range.cloneRange();
            preCaretRange.selectNodeContents(element);
            preCaretRange.setEnd(range.endContainer, range.endOffset);
            caretPos = preCaretRange.toString().length;
        }
    }
    return caretPos;
}

// Helper function to set caret position
function setCaretPosition(element, pos) {
    var range = document.createRange();
    var selection = window.getSelection();
    var textNode = element.firstChild;
    
    if (textNode) {
        pos = Math.min(pos, textNode.length);
        range.setStart(textNode, pos);
        range.setEnd(textNode, pos);
        selection.removeAllRanges();
        selection.addRange(range);
    }
}

function addBookToInvoiceList(data, cnt) {
	// Add validation to prevent issues with invalid data
	if (!data || !data.name || data.price == null) {
		return;
	}

	// For Extra material, use the saved extra amount, otherwise use the book's price
	var displayPrice = data.name === 'Extra' ? parseFloat(data.input) || data.price : data.price;

	var isOdd = (cnt % 2)==1;
	// if cnt is odd number, then apply tr class to row_odd, otherwise set to row_even
	var rowClass = isOdd ? 'row_odd' : 'row_even';
	var row = $('<tr class="'+ rowClass +'">');
	
	// var row = $('<tr>');
	row.append($('<td class="text-center"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>')); // item
	row.append($('<td class="smaller-table-font">').text(data.name || '')); // description
	row.append($('<td>')); // year
	row.append($('<td>')); // day
	row.append($('<td>')); // start
	row.append($('<td>')); // end
	row.append($('<td>')); // weeks 
	row.append($('<td>')); // credit
	row.append($('<td>')); // discount
	row.append($('<td>')); // price	
	row.append($('<td class="smaller-table-font text-right">').addClass('amount').text(Number(displayPrice || 0).toFixed(2)));// Amount	
	row.append($('<td class="smaller-table-font text-center">').text(data.paymentDate || ''));// payment date
	row.append($('<td>').addClass('hidden-column').addClass('book-match').text(BOOK + '|' + (data.bookId || ''))); // 0
	row.append($('<td>').addClass('hidden-column').addClass('material-match').text(BOOK + '|' + (data.id || '')));
	row.append($('<td class="hidden-column materialId">').text(data.id || '')); 
	row.append($('<td class="hidden-column invoiceId">').text(data.invoiceId || '')); 
}


// Add this helper function for calculations
function calculateAmount(row) {
	var startWeek = parseInt(row.find('.start-week').text()) || 0;
	var endWeek = parseInt(row.find('.end-week').text()) || 0;
	var weeks = parseInt(row.find('.weeks').text()) || 0;
	var credit = parseInt(row.find('.credit').text()) || 0;
	var price = parseFloat(row.find('.price').text()) || 0;
	var discount = row.find('.discount').text() || '0';
	var isOnline = row.find('.online').text() === "true";

	// For online classes or 100% discount, amount is always 0
	if (isOnline || discount === '100%') {
		row.find('.amount').text('0.00');
		updateTotalBasket();
		return;
	}

	// Calculate original weeks (without credit extension)
	// This is for proper charging - we extend the class duration with credit
	// but only charge for the original weeks
	var originalWeeks = credit > 0 ? weeks - credit : weeks;
	var amount = originalWeeks * price;

	// Apply discount
	if (discount.includes('%')) {
		var discountPercent = parseFloat(discount.replace('%', '')) || 0;
		amount *= (1 - (discountPercent / 100));
	} else {
		var discountAmount = parseFloat(discount) || 0;
		amount = Math.max(0, amount - discountAmount);
	}

	row.find('.amount').text(amount.toFixed(2));
	updateTotalBasket();
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
						<button id="applyEnrolmentBtn" type="button" class="btn btn-block btn-primary btn-sm" data-toggle="modal" onclick="associateRegistration()"><span class="text-warning">Confirm</span></button>
					</div>
					<div class="col-md-2">
						<button id="startNewEnrolmentBtn" type="button" class="btn btn-block btn-info btn-sm" data-toggle="modal" onclick="removeAllInBasket()">Start New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<nav>
							<div class="nav nav-tabs nav-fill" id="nav-tab" role="tablist">
								<a class="nav-item nav-link active" id="nav-basket-tab" data-toggle="tab" href="#nav-basket" role="tab" aria-controls="nav-basket" aria-selected="true">Purchased Items</a>
								<a class="nav-item nav-link" id="nav-fee-tab" data-toggle="tab" href="#nav-fee" role="tab" aria-controls="nav-fee" aria-selected="true">Class To Choose</a>
								<a class="nav-item nav-link" id="nav-book-tab" data-toggle="tab" href="#nav-book" role="tab" aria-controls="nav-book" aria-selected="false">Material To Choose</a>
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
		
			
	