<script>

	var academicYear;
	var academicWeek;
	
	const ENROLMENT = 'enrolment';
	const ELEARNING = 'eLearning';
	const CLASS = 'class';
	const BOOK = 'book';
	const ETC = 'etc';
	const NEW = 'NEW';
	
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
				// console.log(response);
			  },
			  error: function(jqXHR, textStatus, errorThrown) {
				console.log('Error : ' + errorThrown);
			  }
			});
	
			$('#registerGrade').on('change',function() {
				var grade = $(this).val();
				listElearns(grade);
				listCourses(grade);
				listBooks(grade);
			});
			
			// remove records from basket when click on delete icon
			$('#basketTable').on('click', 'a', function(e) {
				e.preventDefault();
				$(this).closest('tr').remove();
				showAlertMessage('deleteAlert', '<center><i class="bi bi-trash"></i> &nbsp;&nbsp Item is now removed from My Lecture</center>');
			});
		}
	);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//      Search e-Learning based on Grade    
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	// function listElearns(grade) {
	// 	// clear 'elearnTable' table body
	// 	$('#elearnTable tbody').empty();
	// 	$.ajax({
	// 		url : '${pageContext.request.contextPath}/elearning/grade',
	// 		type : 'GET',
	// 		data : {
	// 			grade : grade,
	// 		},
	// 		success : function(data) {
	// 			$.each(data, function(index, value) {
	// 				const cleaned = cleanUpJson(value);
	// 				// console.log(cleaned);
	// 				var row = $("<tr class='d-flex'>");
	// 				row.append($('<td>').addClass('hidden-column').text(value.id));
	// 				row.append($('<td class="col-1"><i class="bi bi-laptop" title="e-learning"></i></td>'));
	// 				row.append($('<td class="smaller-table-font text-center col-1">').text(value.grade.toUpperCase()));
	// 				row.append($('<td class="smaller-table-font col-9" style="padding-left: 20px;">').text(value.name));
	// 				row.append($("<td onclick='addElearningToBasket(" + cleaned + ")''>").html('<a href="javascript:void(0)" title="Add eLearning"><i class="bi bi-plus-circle"></i></a>'));
	// 				$('#elearnTable > tbody').append(row);
	// 			});
	// 		},
	// 		error : function(xhr, status, error) {
	// 			console.log('Error : ' + error);
	// 		}
	// 	});
	// }

// change to async function to make sure 'readyForCourseRegistration() in studentInfo.jsp' executes after 'listElearns()' is completed
async function listElearns(grade) {
    return new Promise(function(resolve, reject) {
        // clear 'elearnTable' table body
        $('#elearnTable tbody').empty();
        $.ajax({
            url: '${pageContext.request.contextPath}/elearning/grade',
            type: 'GET',
            data: {
                grade: grade,
            },
            success: function(data) {
                $.each(data, function(index, value) {
                    const cleaned = cleanUpJson(value);
                    // console.log(cleaned);
                    var row = $("<tr class='d-flex'>");
                    row.append($('<td>').addClass('hidden-column').text(value.id));
                    row.append($('<td class="col-1"><i class="bi bi-laptop" title="e-learning"></i></td>'));
                    row.append($('<td class="smaller-table-font text-center col-1">').text(value.grade.toUpperCase()));
                    row.append($('<td class="smaller-table-font col-9" style="padding-left: 20px;">').text(value.name));
                    row.append($("<td onclick='addElearningToBasket(" + cleaned + ")''>").html('<a href="javascript:void(0)" title="Add eLearning"><i class="bi bi-plus-circle"></i></a>'));
                    $('#elearnTable > tbody').append(row);
                });
                resolve();
            },
            error: function(xhr, status, error) {
                console.log('Error : ' + error);
                reject(error);
            }
        });
    });
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
				grade : grade,
			},
			success : function(data) {
				$.each(data, function(index, value) {
					const cleaned = cleanUpJson(value);
					//console.log(cleaned);
					var row = $('<tr class="d-flex">');
					row.append($('<td>').addClass('hidden-column').text(value.id));
					row.append($('<td class="col-1"><i class="bi bi-mortarboard" title="class"></i></td>'));
					row.append($('<td class="smaller-table-font col-5" style="padding-left: 20px;">').text(value.description));
					row.append($('<td class="smaller-table-font col-4">').text(addSpace(JSON.stringify(value.subjects))));
					row.append($('<td class="smaller-table-font col-1 text-right pr-1">').text(Number(value.price).toFixed(2)));
					row.append($("<td class='col-1' onclick='addClassToBasket(" + cleaned + ")''>").html('<a href="javascript:void(0)" title="Add Class"><i class="bi bi-plus-circle"></i></a>'));
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
					const cleaned = cleanUpJson(value);
					// console.log(cleaned);
					var row = $('<tr class="d-flex">');
					row.append($('<td>').addClass('hidden-column').text(value.id));
					row.append($('<td class="col-1"><i class="bi bi-book" title="book"></i></td>'));
					row.append($('<td class="smaller-table-font col-5">').text(value.name));
					row.append($('<td class="smaller-table-font col-4">').text(addSpace(JSON.stringify(value.subjects))));
					row.append($('<td class="smaller-table-font col-1 text-right pr-1">').text(Number(value.price).toFixed(2)));
					//row.append($("<td class='col-1' onclick='addBookToInvoice(" + cleaned + ")''>").html('<a href="javascript:void(0)" title="Add Book"><i class="bi bi-plus-circle"></i></a>'));
					row.append($("<td class='col-1' onclick='addBookToBasket(" + cleaned + ")''>").html('<a href="javascript:void(0)" title="Add Book"><i class="bi bi-plus-circle"></i></a>'));
					$('#bookTable > tbody').append(row);
				});
			},
			error : function(xhr, status, error) {
				console.log('Error : ' + error);
			}
		});
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//      Add elearning to basket
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	function addElearningToBasket(value){
		// if elearning is already in basket, skip
		if(isSameRowExisting(ELEARNING, value.id)){
			showAlertMessage('warningAlert', '<center><i class="bi bi-laptop"></i> &nbsp;&nbsp[' + value.grade.toUpperCase()+ '] ' + value.name +' is already in My Lecture</center>');
			return;
		}
		var row = $("<tr class='d-flex'>");
		row.append($('<td>').addClass('hidden-column').addClass('data-type').text(ELEARNING + '|' + value.id));
		row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-laptop" title="e-learning"></i></td>'));
		row.append($('<td class="smaller-table-font" style="width: 36%;">').text('[' + value.grade.toUpperCase() + '] ' + value.name));
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 4%;">'));
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 8%;">'));   
		row.append($('<td style="width: 11%;">'));
		row.append($('<td style="width: 4%;">').html('<a href="javascript:void(0)" title="Delete e-learning"><i class="bi bi-trash"></i></a>'));
		row.append($('<td>').addClass('hidden-column').addClass('grade').text(value.grade));
		$('#basketTable > tbody').prepend(row);
		// Automatically dismiss the alert after 2 seconds
		showAlertMessage('addAlert', '<center><i class="bi bi-laptop"></i> &nbsp;&nbsp[' + value.grade.toUpperCase()+ '] ' + value.name +' added to My Lecture</center>');
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//      Add class to basket
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	function addClassToBasket(value) {
	  $.ajax({
		url: '${pageContext.request.contextPath}/class/classesByCourse',
		type: 'GET',
		data: {
		  courseId: value.id,
		  year: value.year
		},
		success: function(data) {
			//console.log(data);
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
			var row = $('<tr class="d-flex">');
			// dynamic clazz id assign
			var dropdown = $('<select class="clazzChoice">');
			$.each(data, function(index, clazz) {
				var option = $('<option>').text(clazz.day).val(clazz.id);
				dropdown.append(option);
			});
			// Get the value of the first option
			var initialValue = dropdown.find('option:first').val();
			// Initialize the hidden column with the initial value
			var hiddenColumn = $('<td>').addClass('hidden-column data-type').text(CLASS +'|' + initialValue);
			dropdown.on('change', function() {
				var selectedValue = $(this).val();
				// Update the hidden column's text with the selected value
				hiddenColumn.text(CLASS +'|' + selectedValue);
			});
			row.append(hiddenColumn);
			row.append($('<td class="text-center"><i class="bi bi-mortarboard" title="class"></i></td>')); // item
			row.append($('<td class="smaller-table-font name">').text(value.name)); // name
			row.append($('<td class="smaller-table-font day">').append(dropdown)); // day
			row.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year
	
			var startWeekCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('start-week').text(start_week); // start week
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
			});
			row.append(startWeekCell);
			
			var endWeekCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('end-week').text(end_week); // end week
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
			});
			row.append(endWeekCell);
	
			var weeksCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('weeks').text((end_week - start_week) + 1);// weeks  
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
			});
			row.append(weeksCell);
	
			var creditCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('credit').text(0); // credit
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
			});
			row.append(discountCell);
	
			row.append($('<td class="smaller-table-font text-center price">').text(value.price)); // price
			row.append($('<td class="smaller-table-font text-center">').addClass('amount').text(((weeksCell.text() * value.price)).toFixed(2))); // amount					
			row.append($('<td>').html('<a href="javascript:void(0)" title="Delete class"><i class="bi bi-trash"></i></a>'));
			row.append($('<td class="hidden-column enrolId">').text('')); // enrolId
			row.append($('<td class="hidden-column invoiceId">').text('')); // invoiceId
			row.append($('<td class="hidden-column grade">').text(value.grade)); // grade
			row.append($('<td class="hidden-column description">').text(value.description)); // description
			$('#basketTable > tbody').prepend(row);
			
			showAlertMessage('addAlert', '<center><i class="bi bi-mortarboard"></i> &nbsp;&nbsp' + value.description + ' added to My Lecture</center>');
		}
	  });
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//      Add book to basket
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	function addBookToBasket(value){
		//console.log(value);
		// if book is already in basket, skip
		if(isSameRowExisting(BOOK, value.id)){
			showAlertMessage('warningAlert', '<center><i class="bi bi-book"></i> &nbsp;&nbsp' + value.name +' is already in My Lecture</center>');
			return;
		}
		var row = $('<tr class="d-flex">');
		row.append($('<td>').addClass('hidden-column').addClass('data-type').text(BOOK + '|' + value.id)); // 0
		row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book" title="book"></i></td>')); // item
		row.append($('<td class="smaller-table-font name" style="width: 36%;">').text(value.name)); // name
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 6%;">'));
		row.append($('<td style="width: 4%;">'));
		row.append($('<td style="width: 7%;">'));
		row.append($('<td style="width: 8%;">')); // price
		// row.append($('<td class="smaller-table-font text-center price" style="width: 11%;">').text(value.price.toFixed(2)));
		row.append($('<td class="smaller-table-font text-center price" style="width: 11%;">').text(Number(value.price).toFixed(2)));
		row.append($('<td style="width: 4%;">').html('<a href="javascript:void(0)" title="Delete book"><i class="bi bi-trash"></i></a>')); // Action
		row.append($('<td>').addClass('hidden-column').addClass('grade').text(value.grade)); 
		$('#basketTable > tbody').prepend(row);
		
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
	
		var elearnings = [];
		var enrolData = [];
		var books = [];
	
		$('#basketTable tbody tr').each(function() {
			// in case of update, enrolId is not null
			//debugger;
			var clazzId = null;
			var bookId = null;
			var hiddens = $(this).find('.data-type').text();
			if(hiddens.indexOf('|') !== -1){
				var hiddenValues = hiddens.split('|');
				// if hiddenValues[0] is ELEARNING, push hiddenValues[1] to elearnings array
				if(hiddenValues[0] === ELEARNING){
					elearnings.push(hiddenValues[1]);
					return true;
				}else if(hiddenValues[0] === BOOK){
					books.push(hiddenValues[1]);
					return true;
				}else if(hiddenValues[0] === CLASS){
					clazzId = hiddenValues[1];
				}
			}
	
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
				"studentId" : studentId
			};
			enrolData.push(clazz);
			// how to jump to next <tr>             
			return true;    
		});
	
		var elearningData = elearnings.map(function(id) {
			return parseInt(id);
		});
		var bookData = books.map(function(id){
			return parseInt(id);
		});
	
		// Make the AJAX enrolment for eLearning
		$.ajax({
			url: '${pageContext.request.contextPath}/enrolment/associateElearning/' + studentId,
			method: 'POST',
			data: JSON.stringify(elearningData),
			contentType: 'application/json',
			success: function(response) {
				// Handle the response
				// console.log(response);
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
		});
		
		//console.log(enrolData);
	
		// 1. Make the AJAX enrolment for class
		$.ajax({
			url: '${pageContext.request.contextPath}/enrolment/associateClazz/' + studentId,
			method: 'POST',
			data: JSON.stringify(enrolData),
			contentType: 'application/json',
			success: function(response) {
				//debugger;
				removeEnrolmentFromInvoiceList();	
				// need to clear existing Outstanding??
				removeOutstandingFromInvoiceList();

				if(response.length >0){
					$.each(response, function(index, value){
						// if extra is NEW, it requires updating enrolment id in basket table
						if(value.extra != null && value.extra === NEW){
							// how to add enrolment id to basket table
							$('#basketTable > tbody > tr').each(function() {
								var hiddens = $(this).find('.data-type').text();
								if ((hiddens.indexOf(CLASS) !== -1) && (hiddens.indexOf('|') !== -1)) {
									var hiddenValues = hiddens.split('|');
									if(hiddenValues[1]===value.clazzId){
										// console.log(hiddens + ' - ' + value.clazzId);
										$(this).find('.enrolId').text(value.id);
										$(this).find('.invoiceId').text(value.invoiceId);
										$(this).find('.clazzChoice').prop('disabled', true);		
									}
								}
							});

						}
						// update the invoice table 
						addEnrolmentToInvoiceList(value);
					});
				}else{
					// simply update balance for invoice table as Enrolment is deleted
					if(enrolData.invoiceId != null && enrolData.invoiceId != ''){
						updateLatestInvoiceId(enrolData.invoiceId);
					}
				}
				
				// nested ajax for book after creating or updating invoice
				// 2. Make the AJAX enrolment for book
				$.ajax({
					url: '${pageContext.request.contextPath}/enrolment/associateBook/' + studentId,
					method: 'POST',
					data: JSON.stringify(bookData),
					contentType: 'application/json',
					success: function(response) {
						// remove books from invoice table
						removeBookFromInvoiceList();
						// Handle the response
						if(response.length >0){
							$.each(response, function(index, value){
								// console.log(value);
								addBookToInvoiceList(value);
							});
						}else{
							// simply update balance for invoice table as Book is deleted
							if(enrolData.invoiceId != null && enrolData.invoiceId != ''){
								updateLatestInvoiceId(enrolData.invoiceId);
							}
						}
					},
					error: function(xhr, status, error) {
						// Handle the error
						console.error(error);
					}
				});
	
				// check how many rows in basketTable table
				var rowCount = $('#basketTable tbody tr').length;
				// console.log(rowCount);
	
				// Handle the response
				// console.log(response);
				$('#success-alert .modal-body').html('ID : <b>' + studentId + '</b> enrolment saved successfully');
				$('#success-alert').modal('toggle');
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
		});
	
		// need to check whether any exisiting Outstanding
		$.ajax({
			url: '${pageContext.request.contextPath}/enrolment/associateOutstanding/' + studentId,
			method: 'POST',
			contentType: 'application/json',
			success: function(response) {
				// remove outstandings from invoice table
				removeOutstandingFromInvoiceList();
				// Handle the response
				if(response.length >0){
					$.each(response, function(index, value){
						// console.log(value);
						addOutstandingToInvoiceList(value);
					});
				}
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
		});
		
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//      Retrieve Enroloment & Update Invoice Table
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	function retrieveEnrolment(studentId){
		// get the enrolment
		$.ajax({
			url: '${pageContext.request.contextPath}/enrolment/search/student/' + studentId,
			method: 'GET',
			success: function(response) {
				// Handle the response
				$.each(response, function(index, value){
					//debugger;
					// It is an EnrolmentDTO object     
					if (value.hasOwnProperty('extra')) {
						// update my lecture table
						var row = $('<tr class="d-flex">');
						row.append($('<td>').addClass('hidden-column').addClass('data-type').text(CLASS + '|' + value.clazzId));
						row.append($('<td class="text-center"><i class="bi bi-mortarboard" title="class"></i></td>')); // item
						row.append($('<td class="smaller-table-font name">').text(value.name)); // name
						row.append($('<td class="smaller-table-font day">').text(value.day)); // day
						row.append($('<td class="smaller-table-font text-center year">').text(value.year)); // year

						// row.append($('<td class="smaller-table-font text-center" contenteditable="true">').addClass('start-week').text(value.startWeek)); // start week
						var startWeekCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('start-week').text(value.startWeek); // start week
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
						});
						row.append(startWeekCell);

						// row.append($('<td class="smaller-table-font text-center" contenteditable="true">').addClass('end-week').text(value.endWeek)); // end week
						var endWeekCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('end-week').text(value.endWeek); // end week
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
						});
						row.append(endWeekCell);

						// row.append($('<td class="smaller-table-font text-center" contenteditable="true">').addClass('weeks').text(value.endWeek - value.startWeek + 1)); // weeks
						var weeksCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('weeks').text((value.endWeek - value.startWeek) + 1);// weeks  
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
						});
						row.append(weeksCell);

						// row.append($('<td class="smaller-table-font text-center credit" contenteditable="true">').text(value.credit)); // credit
						var creditCell = $('<td class="smaller-table-font text-center" contenteditable="true">').addClass('credit').text(value.credit); // credit
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
						row.append($("<td>").html('<a href="javascript:void(0)" title="Delete class"><i class="bi bi-trash"></i></a>'));
						row.append($('<td class="hidden-column invoiceId">').text(value.invoiceId)); // invoiceId
						row.append($('<td class="hidden-column grade">').text(value.grade)); // grade
						row.append($('<td class="hidden-column description">').text(value.description)); // description
						row.append($('<td class="hidden-column enrolId">').text(value.id)); // enrolmentId
						row.append($('<td class="hidden-column invoiceAmount">').text(value.amount)); // invoice amount	
						row.append($('<td class="hidden-column paid">').text(value.paid)); // paid	
		
						$('#basketTable > tbody').prepend(row);

						// update invoice table with Enrolment
						addEnrolmentToInvoiceList(value);
					} else if (value.hasOwnProperty('remaining')) { // It is an OutstandingDTO object
						// update invoice table with Outstanding
						addOutstandingToInvoiceList(value);
					}else{  // Book
						// update my lecture table
						var row = $('<tr class="d-flex">');
						row.append($('<td>').addClass('hidden-column').addClass('data-type').text(BOOK + '|' + value.bookId)); // 0
						row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-book" title="book"></i></td>')); // item
						row.append($('<td class="smaller-table-font" style="width: 36%;">').text(value.name)); // name
						row.append($('<td style="width: 7%;">'));
						row.append($('<td style="width: 6%;">'));
						row.append($('<td style="width: 6%;">'));
						row.append($('<td style="width: 6%;">'));
						row.append($('<td style="width: 4%;">'));
						row.append($('<td style="width: 7%;">'));
						row.append($('<td style="width: 8%;">')); // price
						row.append($('<td class="smaller-table-font text-center price" style="width: 11%;">').text(value.price.toFixed(2)));
						row.append($("<td style='width: 4%;'>").html('<a href="javascript:void(0)" title="Delete book"><i class="bi bi-trash"></i></a>')); // Action
						row.append($('<td class="hidden-column grade">').text(value.grade));
						row.append($('<td class="hidden-column materialId">').text(value.id)); 
						row.append($('<td class="hidden-column invoiceId">').text(value.invoiceId)); 
						
						$('#basketTable > tbody').prepend(row);
						// update invoice table with Book
						addBookToInvoiceList(value);
					}
				});
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
		});
		// get the elearning
		$.ajax({
			url: '${pageContext.request.contextPath}/elearning/search/student/' + studentId,
			method: 'GET',
			success: function(response) {
				// Handle the response
				$.each(response, function(index, value){
					// console.log(index + ' - ' + value);  
					// if already exist the same row, skip
					if(isSameRowExisting(ELEARNING, value.id)){
						// console.log('existing...');
						return true;
					}
					var row = $("<tr class='d-flex'>");
					row.append($('<td>').addClass('hidden-column').addClass('data-type').text(ELEARNING + '|' + value.id));
					row.append($('<td class="text-center" style="width: 5%;"><i class="bi bi-laptop" title="e-learning"></i></td>'));
					row.append($('<td class="smaller-table-font" style="width: 36%;">').text('[' + value.grade.toUpperCase() + '] ' + value.name));
					row.append($('<td style="width: 7%;">'));
					row.append($('<td style="width: 6%;">'));
					row.append($('<td style="width: 6%;">'));
					row.append($('<td style="width: 6%;">'));
					row.append($('<td style="width: 4%;">'));
					row.append($('<td style="width: 7%;">'));
					row.append($('<td style="width: 8%;">'));   
					row.append($('<td style="width: 11%;">'));
					row.append($('<td style="width: 4%;">').html('<a href="javascript:void(0)" title="Delete e-learning"><i class="bi bi-trash"></i></a>'));
					row.append($('<td>').addClass('hidden-column').addClass('grade').text(value.grade));
	
					$('#basketTable > tbody').append(row);  
	
				});
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
		});
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
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//      Display Subject List
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	function addSpace(str) {
	  if(!str.match(/[\[\]"]/gi)) { // check if str contains '[', ']', or "
		return str; // if not, return original str
	  } else {
		str = str.replace(/[\[\]"]/gi, ''); // remove '[', ']', "" from JSON.stringify
		return str.replace(/,/g, ', '); // Use regex expression to replace commas with commas and space
	  }
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
		#basketTable th:nth-child(3) { width: 23%; } /* name */
		#basketTable th:nth-child(4) { width: 13%; } /* day */
		#basketTable th:nth-child(5) { width: 7%; } /* year */
		#basketTable th:nth-child(6) { width: 6%; } /* start */
		#basketTable th:nth-child(7) { width: 6%; } /* end */
		#basketTable th:nth-child(8) { width: 6%; } /* weeks */
		#basketTable th:nth-child(9) { width: 4%; } /* credit % */
		#basketTable th:nth-child(10) { width: 7%; } /* discount % */
		#basketTable th:nth-child(11) { width: 8%; } /* price */
		#basketTable th:nth-child(12) { width: 11%; } /* amount */
		#basketTable th:nth-child(13) { width: 4%; } /* delete */
	
		#basketTable td:nth-child(1) { width: 0%; } /* hidden id */
		#basketTable td:nth-child(2) { width: 5%; }  /* item */
		#basketTable td:nth-child(3) { width: 23%; } /* name */
		#basketTable td:nth-child(4) { width: 13%; } /* day */
		#basketTable td:nth-child(5) { width: 7%; } /* year */
		#basketTable td:nth-child(6) { width: 6%; } /* start */
		#basketTable td:nth-child(7) { width: 6%; } /* end */
		#basketTable td:nth-child(8) { width: 6%; } /* weeks */
		#basketTable td:nth-child(9) { width: 4%; } /* credit % */
		#basketTable td:nth-child(10) { width: 7%; } /* discount % */
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
					<div class="offset-md-6">
					</div>
					<div class="col-md-2">
						<button id="applyEnrolmentBtn" type="button" class="btn btn-block btn-primary btn-sm" data-toggle="modal" onclick="associateRegistration()">Enrolment</button>
					</div>
					<!-- <div class="col-md-2">
						<button id="deleteEnrolmentBtn" type="button" class="btn btn-block btn-danger btn-sm" data-toggle="modal" onclick="deleteRegistration()">Delete</button>
					</div> -->
					<div class="col-md-2">
						<button id="clearEnrolmentBtn" type="button" class="btn btn-block btn-success btn-sm" data-toggle="modal" onclick="clearEnrolmentBasket()">Clear</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<nav>
							  <div class="nav nav-tabs nav-fill" id="nav-tab" role="tablist">
									<a class="nav-item nav-link active" id="nav-basket-tab" data-toggle="tab" href="#nav-basket" role="tab" aria-controls="nav-basket" aria-selected="true">Lecture</a>
									<a class="nav-item nav-link" id="nav-elearn-tab" data-toggle="tab" href="#nav-elearn" role="tab" aria-controls="nav-elearn" aria-selected="true">e-Learning</a>
									<a class="nav-item nav-link" id="nav-fee-tab" data-toggle="tab" href="#nav-fee" role="tab" aria-controls="nav-fee" aria-selected="true">Course</a>
									<a class="nav-item nav-link" id="nav-book-tab" data-toggle="tab" href="#nav-book" role="tab" aria-controls="nav-book" aria-selected="false">Books</a>
									<!-- <a class="nav-item nav-link" id="nav-etc-tab" data-toggle="tab" href="#nav-etc" role="tab" aria-controls="nav-etc" aria-selected="false">Etc</a> -->
							  </div>
						</nav>                  
						<div class="tab-content" id="nav-tabContent">
						<!-- Lecture List -->
						<div class="tab-pane fade show active" id="nav-basket" role="tabpanel" aria-labelledby="nav-basket-tab">
							<table class="table" id="basketTable" name="basketTable">
								<thead>
									<tr class="d-flex">
										<th class="hidden-column"></th>
										<th class="smaller-table-font text-center" style="padding-left: 0.25rem;">Item</th>
										<th class="smaller-table-font text-center">Name</th>
										<th class="smaller-table-font text-center">Day</th>
										<th class="smaller-table-font text-center">Year</th>
										<th class="smaller-table-font text-center">Start</th>
										<th class="smaller-table-font text-center">End</th>
										<th class="smaller-table-font text-center">Wks</th>
										<th class="smaller-table-font text-center">CR</th>
										<th class="smaller-table-font text-center">DC</th>
										<th class="smaller-table-font text-center">Price</th>
										<th class="smaller-table-font text-center">Amount</th>
										<th class="smaller-table-font text-center hidden-column"></th>
									</tr>
								</thead>
								<tbody>	
								</tbody>
							</table> 
						</div>
						<!-- e-Learning -->
						<div class="tab-pane fade" id="nav-elearn" role="tabpanel" aria-labelledby="nav-elearn-tab">
							<table class="table" id="elearnTable" name="elearnTable">
								<thead>
									<tr class="d-flex">
										<th class="hidden-column"></th>
										<th class="smaller-table-font col-1">Item</th>
										<th class="smaller-table-font col-1">Grade</th>
										<th class="smaller-table-font col-9" style="padding-left: 20px;">Subjects</th>
										<th class="col-1"></th>
									</tr>
								</thead>
								<tbody>	
								</tbody>
							</table>
						</div>
						<!-- Course -->
						<div class="tab-pane fade" id="nav-fee" role="tabpanel" aria-labelledby="nav-fee-tab">
							<table class="table" id="courseTable" name="courseTable">
								<thead>
									<tr class="d-flex">
										<th class="hidden-column"></th>
										<th class="smaller-table-font col-1">Item</th>
										<th class="smaller-table-font col-5" style="padding-left: 20px;">Name</th>
										<th class="smaller-table-font col-4" style="padding-left: 20px;">Subjects</th>
										<th class="smaller-table-font col-1">Price</th>
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
<script src="${pageContext.request.contextPath}/js/bootstrap-table.min.js"></script>
		
			
	