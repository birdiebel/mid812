
$( document ).ready(function() {

    var zones = ['par_str','dist_str']

    // Select first input
    $(".score-input").first().select(); 

    // Visual val = 0
    $(".score-input").each(function() {
        if($(this).val() == 0) {
            $(this).css("background-color","pink")
            $(this).val("")
        }    
    })

    // Select first free input (value empty)
    $(".score-input").each(function(){
        if ($(this).val() === "" ) {
            $(this).select();
            return false;
        }
    });

    // Show all totals
    show_all_total(zones)

    create_db_field('par_str')
    create_db_field('dist_str')
    create_db_field('stroke_str')


    // Number Only
    $('.score-input').ForceNumericOnly();

    // Enter Score
    $('.score-input').GetScoreInput();

});

$.fn.GetScoreInput = function(e) {
    $('.score-input').keyup(function(e) {
            e.preventDefault()
            keyCode = e.keyCode
            limit = parseInt($(this).attr("limit"))
            zone = $(this).attr("zone")
            switch (keyCode) {
                case 9 :
                    break
                case 16 :
                    break
                case 46 :
                    break
                default:
                    
                    if ($(this).val() > limit) {        
                        $(this).blur();
                        var inputs = $(this).closest('.table-card').find('.score-input');
                        inputs.eq(inputs.index(this) + 1).focus().select();
                        $(this).css('background-color','white');
                    };
                    if ($(this).val() == 0) {
                        $(this).css('background-color','pink');     
                    }                    
            }

            show_total(zone)
            create_db_field(zone)

        });        
}

$.fn.ForceNumericOnly = function(e) {
    $(this).keydown(function(e)
        {
            var key = e.charCode || e.keyCode || 0;
            // allow backspace, tab, delete, arrows, numbers and keypad numbers ONLY
            return (
                key == 8 || 
                key == 9 ||
                key == 46 ||
                (key >= 37 && key <= 40) ||
                (key >= 48 && key <= 57) ||
                (key >= 96 && key <= 105));
    })
};

function create_db_field(zone) {

    inputValues = $("input[zone='"+zone+"'][hole]").map(function() {
        return parseInt($(this).val());
    }).toArray();
    console.log(inputValues)
    $('#tee_'+zone).val(inputValues.join(','))

}


// $.fn.CreateDbField = function(e) {

//     inputValues = $("input[zone='"+zone+"'][hole]").map(function() {
//         return parseInt($(this).val());
//     }).toArray();
//     console.log(inputValues)
//     $('#tee_'+zone).val(inputValues.join(','))

// }

// Sum row
function sum_input(zone, start, stop, to_id) {
    var total = 0;
    $("input[zone='"+zone+"'][hole]").each(function() {
        var thisValue = parseInt($(this).attr('hole'));    
        if (thisValue >= start && thisValue <= stop) {
            total += parseInt($(this).val(), 10) || 0;
        }
    });
    $("#"+to_id).text(total)
}

// Show zone totals
function show_total(zone) {
    sum_input(zone,1,9,zone+"-front")
    sum_input(zone,10,18,zone+"-back")
    sum_input(zone,1,18,zone+"-total")
}

// Show all totals
function show_all_total(zones) {
    zones.forEach((item) => {
        show_total(item)
    })
}