$( document ).ready(function() {

    console.log("Card js is ready");

    var nb_players = +($("#nb_cards").text());

    var player;

    // Store Card_player score_txt values to inputs:brut and array
    for (player = 1; player <= nb_players ; player++) {

        // Create brut_array from form.score_txt
        var initial_score = $(read_initial_brut(player)).val();
        var brut_array = initial_score.split(",");

        // Store each input:brut from brut_array
        var i;
        for (i = 0; i <= 17 ; i++) {
            $(select_input(player, i)).val(brut_array[i]);
        }

        // Show net row values
        show_computed_net(player);

        // Show stb row values
        show_computed_stb(player);

        // Show Totaux
        show_totaux(player);

    }

    // Change Brut input player
    $(select_all_input(1)).change(function () {
        write_initial_brut(1);
        // Show Totaux
        show_totaux(1);
    });
    $(select_all_input(2)).change(function () {
        write_initial_brut(2);
        // Show Totaux
        show_totaux(2);
    });
    $(select_all_input(3)).change(function () {
        write_initial_brut(3);
        // Show Totaux
        show_totaux(3);
    });
    $(select_all_input(4)).change(function () {
        write_initial_brut(4);
        // Show Totaux
        show_totaux(4);
    });

    // Select first free input (value 0)
    $("input.brut").each(function(){
        if ($(this).val() === "0" ) {
            $(this).select();
            return false;
        }
    });

    $('.brut').ForceNumericOnly();

    $('.brut').keydown(function(e){
        var key = e.charCode || e.keyCode || 0;
        var value = $(this).val();
        if ( value.length === 0 && key === 9) {
            console.log("KEYDOWN TAB AND EMPTY");
            return false
        }
    });

    $('.brut').keyup(function(e){

        var key = e.charCode || e.keyCode || 0;

        var value = $(this).val();

        if ( value.length === 0 ) {
            return false;
        }

        if ( key === 97 && value.length < 2 ) {

        } else {

            if (
                key === 8 ||
                key === 9 ||
                key === 13 ||
                key === 46 ||
                key === 106 ||
                (key >= 35 && key <= 40) ||
                (key >= 48 && key <= 57) ||
                (key >= 96 && key <= 105)
            ) {
                console.log("charcode : " + key);
                if ($(this).val() === "") {
                    $(this).val(0)
                }
                $(this).blur();
                //var inputs = $(this).closest('.input-scorecard').find(':input');
                var inputs = $(this).closest('.input-scorecard').find('.brut');
                inputs.eq(inputs.index(this) + 1).focus().select();
            }
        }
    });

});

function read_initial_brut(player) {
    return "input.initial_brut[player='"+player+"']";
}

function write_initial_brut(player) {

    inputValues = $( select_all_input(player) ).map(function() {
        return $(this).val();
    }).toArray();

    // Update initial_brut input
    $( read_initial_brut(player) ).val(inputValues);

    // Show net row values
    show_computed_net(player);

    // Show stb row values
    show_computed_stb(player);

}

function select_input(player, hole) {
    return "input[player='"+player+"'][hole='"+hole+"']";
}

function select_all_input(player) {
    return "input.brut[player='"+player+"']";
}

function select_input_value(player, hole) {
    var selector = "input[player='"+player+"'][hole='"+hole+"']";
    return parseInt($(selector).val());
}

function select_computed_td(zone, player, hole) {
    return "."+zone+"[player='"+player+"'][hole='"+hole+"']";
}

function select_all_computed_td(zone, player) {
    return "."+zone+"[player='"+player+"']";
}

function select_computed_td_value(zone, player, hole) {
    var selector = "."+zone+"[player='"+player+"'][hole='"+hole+"']";
    return parseInt($(selector).text());
}

function select_par_value(player,hole) {
    var selector = ".par[player='"+player+"'][hole='"+hole+"']";
    return parseInt($(selector).text());
}

function show_computed_net(player) {
    var i;
    for (i = 0; i <= 17 ; i++) {
        var brut = select_input_value(player, i);
        var recu = select_computed_td_value("recu", player, i);
        var net = get_value_net(brut, recu, i);
        $(select_computed_td("net", player, i)).text(net)
    }

}

function show_computed_stb(player) {
    var i;
    for (i = 0; i <= 17 ; i++) {
        var par = select_par_value(player,i);
        var brut = select_input_value(player, i);
        var recu = select_computed_td_value("recu", player, i);
        var net = get_value_net(brut, recu, i);
        var stb = get_value_stb(par, net, brut);
        $(select_computed_td("stb", player, i)).text(stb)
    }
}

function get_value_net(brut, recu, hole) {
    if (!brut) {
        return "";
    }
    if (brut === 0) {
        return "";
    }
    if (!recu) {
        recu = 0;
    }
    var net = (brut - recu);

    return net;
}

function get_value_stb(par, net, brut) {
    if (!brut) {
        return "";
    }

    var stb = (par - net) +2;
    if (stb < 0) {
        stb = "x";
    }

    return stb;
}

function show_totaux(player) {
    show_totaux_brut('brut', player);
    show_totaux_zone('net', player);
    show_totaux_zone('stb', player);
}

function show_totaux_brut(zone, player) {
    var frontPoints = 0;
    var backPoints = 0;
    var totalPoints = 0;
    var i=0;
    var brut;
    var brut_valid=true;

    $( select_all_input(player) ).each(function(){
        brut = $(this).val();
        if ( brut === "*") { brut_valid = false }
        if ( !brut ) { brut = "0"; }
        if(i <= 8 ) {
            frontPoints += parseInt(brut);
        } else {
            backPoints += parseInt(brut);
        }
        i += 1;
        // Check if input is empty
        if ( $(this).val() === "") {
            $(this).addClass("bg-danger")
        } else {
            $(this).removeClass("bg-danger")
        }
    });

    totalPoints += (frontPoints + backPoints);
    if (frontPoints === 0) { frontPoints = "" }
    if (backPoints === 0) { backPoints = "" }
    if (totalPoints === 0) { totalPoints = "" }

    if (!brut_valid) {
        frontPoints = "x";
        backPoints = "x";
        totalPoints = "x";
    }

    $("."+zone+"_front[player='"+player+"']").text(frontPoints);
    $("."+zone+"_back[player='"+player+"']").text(backPoints);
    $("."+zone+"_total[player='"+player+"']").text(totalPoints);

    return true
}

function show_totaux_zone(zone, player) {
    var frontPoints = 0;
    var backPoints = 0;
    var totalPoints = 0;
    var i=0;
    var value;
    $( select_all_computed_td(zone,player) ).each(function(){
        value = parseInt($(this).text());
        if ( !value ) { value = 0}
        if(i <= 8 ) {
            frontPoints += value;
        } else {
            backPoints += value;
        }
        i += 1;
    });
    totalPoints += (frontPoints + backPoints);
    if (frontPoints === 0) { frontPoints = "" }
    if (backPoints === 0) { backPoints = "" }
    if (totalPoints === 0) { totalPoints = "" }
    $("."+zone+"_front[player='"+player+"']").text(frontPoints);
    $("."+zone+"_back[player='"+player+"']").text(backPoints);
    $("."+zone+"_total[player='"+player+"']").text(totalPoints);

    return true
}