$(document).ready(function(){
	 var flag, i ,j;
	 var object_counter = 1;
	 var imgNameRand = [];
	 var optPosition = [];
	 var optOtherPos = [];
	 var imageObject = [];
	 var correctPosition;
	 var selectedOption;
	 var score = 0;
	 var wrong_selected = 0;  //wrong option selected so don't score up
	 var pos;
	 var t;
	 var current_image;
	 
	 
	 load_images();  //load the image numbers for random display
	 display_score();
	 game();     //let the game begin
	 

	 function display_score(){
		 document.scoreDisplay.score.value = score;
		 if(object_counter > 6)
			 document.scoreDisplay.total.value = 6;
		 else
			 document.scoreDisplay.total.value = object_counter;
	 }
	 
	 function checkDisplay(){   //Displays the correct and incorrect info
		 if(wrong_selected == 1){
			 $('.checkedOption').show();
			  document.getElementById("check").src = "assets/images/incorrect.png";
		       $('.checkedOption').fadeOut(1000);
		 }
		 else{
			 $('.checkedOption').hide();
			  document.getElementById("check").src = "assets/images/correct.png";
			  $('.checkedOption').fadeOut(2000);
			 //needs timer for holding on for abt a sec
		 }
	 }
	 
	 $("#anchorPlayAgain").click(function(){
		 $('#gameOver').hide();
		 $('.optImg').show();
		 $('.imageBox').show();
		 load_images();
		 score = 0;
		 object_counter = 1;
		 wrong_selected = 0;
		 display_score();
		 
		 game();
		 
	 });
	 $("#anchorOpt0").click(function(){
		 selected_Option_Process('0');		 
	 });
	 $("#anchorOpt1").click(function(){
		 selected_Option_Process('1');		 
	 });
	 $("#anchorOpt2").click(function(){
		 selected_Option_Process('2');		 
	 });
	 $("#anchorOpt3").click(function(){
		 selected_Option_Process('3');		 
	 });
	 
	 function generate_random_no(no_limit)	{                //generate random number
		var rand_no = Math.ceil(no_limit*Math.random());
		return rand_no;
	}
	
	function get_random_position(){           //generate random number between 0-3
		var rand_pos = Math.floor(Math.random()*4);
		return rand_pos;
	}
	
	function load_images(){
		
		imageObject[0] = generate_random_no("6");
			for(i=1; i<6; i++){
				do{
					flag = 0;
					imageObject[i] = generate_random_no("6");
					for(j=0; j<i; j++){
						if(imageObject[i]===imageObject[j]){
							flag++;
						}
					}
				}while(flag != 0 );  //end of do while loop	
			}
			
				
	}
		function selected_Option_Process(selectedOption){
			
				if(selectedOption == correctPosition){
					object_counter++;
					if(wrong_selected == 0){
				   	  score++;
					}
					wrong_selected = 0;
				   display_score();
				   checkDisplay();
				   //t=setTimeout('game()',1000);
				   game();
				}
				else {
				 wrong_selected = 1;
			 	 checkDisplay();
				}
			
			}
	function game(){
		
		
		//clearTimeout(t);
		wrong_selected = 0;
		current_image = object_counter-1;
		document.getElementById("imgObject").src = "assets/images/"+imageObject[current_image]+".png";
		
		//find correct answer and apply it to the position
		currentImage = imageObject[current_image];
		imgNameRand[0] = currentImage; 
		//generate choices
		
		for(i=1; i<4; i++){
			do{
				flag = 0;
				imgNameRand[i] = generate_random_no("6");
				for(j=0; j<i; j++){
					if(imgNameRand[i]===imgNameRand[j]){
						flag++;
					}
				}
			}while(flag != 0 );  //end of do while loop	
		}
	
		
		correctPosition = get_random_position();
			
		optOtherPos[0] = correctPosition;
		
		for(i=1; i<4; i++){
			do{
				flag = 0;
				optOtherPos[i] = get_random_position();
					for(j=0; j<i; j++){   //chek repeat within optOtherPos array
						if(optOtherPos[i] === optOtherPos[j]){
							flag++;
						}
					}
				
			}while(flag != 0);
				
		}
		
		for(i=0; i<4; i++){
			pos = optOtherPos[i];
			optPosition[pos] = imgNameRand[i];
		}
		

		//random positions are stored in optOtherPos array. Great
				
	
		   for(i=0; i<4; i++){
			   document.getElementById("option"+i+"").src = "assets/images/image_name/"+optPosition[i]+".png";
			}
			
		//check for the correctness
		if(object_counter > 6){
			
			$('.optImg').hide();
			$('.imageBox').hide();
			$('#gameOver').show();
			
		    
		}
		
		 //else
		    //no change
	} //end of game
});  //end of DOM