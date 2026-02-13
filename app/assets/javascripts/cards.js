function init_cards() {
    if ($("#nb_cards").length === 0) {
        return;
    }

    console.log("Card js is ready");

    var nb_players = parseInt($("#nb_cards").text(), 10) || 0;
    var nb_hole = get_nb_hole();

    // Store Card_player score_txt values to inputs:brut and array
    for (var player = 1; player <= nb_players ; player++) {

        // Create brut_array from form.score_txt
        var initial_score = $(read_initial_brut(player)).val();
        var brut_array = (initial_score || "").split(",");

        // Store each input:brut from brut_array
        var i;
        for (i = 0; i < nb_hole ; i++) {
            var brut_value = brut_array[i] !== undefined ? brut_array[i] : "";
            $(select_input(player, i)).val(brut_value);
        }

        // Show net row values
        show_computed_net(player);

        // Show stb row values
        show_computed_stb(player);

        // Show Totaux
        show_totaux(player);

    }

    // Change Brut input player (instant update)
    for (var p = 1; p <= nb_players; p++) {
        $(select_all_input(p)).off("input change.cards").on("input change.cards", function () {
            var currentPlayer = parseInt($(this).attr("player"), 10);
            if (!currentPlayer) {
                return;
            }
            write_initial_brut(currentPlayer);
            // Show Totaux
            show_totaux(currentPlayer);
        });
    }

    // Select first free input (value empty)
    $("input.brut").each(function(){
        if ($(this).val() === "" ) {
            $(this).select();
            return false;
        }
    });

    $('.brut').ForceNumericOnly();

    // Handle backspace to go to previous input and delete its content
    $('.brut').keydown(function(e){
        var key = e.charCode || e.keyCode || 0;
        var value = $(this).val();
        
        // If Enter key, submit the form
        if (key === 13) {
            e.preventDefault();
            $(this).closest('form').submit();
            return false;
        }
        
        // If backspace and input is empty, go to previous input and clear it
        if (key === 8 && value.length === 0) {
            e.preventDefault();
            var inputs = $(this).closest('.input-scorecard').find('.brut');
            var currentIndex = inputs.index(this);
            if (currentIndex > 0) {
                var prevInput = inputs.eq(currentIndex - 1);
                prevInput.val('').focus();
                // Trigger recalculation
                var player = parseInt(prevInput.attr("player"), 10);
                if (player) {
                    write_initial_brut(player);
                    show_totaux(player);
                }
            }
            return false;
        }
        
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

}

$(document).ready(function() {
    init_cards();
});

$(document).on("turbo:load", function() {
    init_cards();
});

function read_initial_brut(player) {
    return "input.initial_brut[player='"+player+"']";
}

function read_initial_zone(zone, player) {
    return "input.initial_"+zone+"[player='"+player+"']";
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
    var nb_hole = get_nb_hole();
    var netValues = [];
    var i;
    for (i = 0; i < nb_hole ; i++) {
        var brut = select_input_value(player, i);
        var recu = select_computed_td_value("recu", player, i);
        var net = get_value_net(brut, recu, i);
        $(select_computed_td("net", player, i)).text(net)
        netValues.push(net === undefined || net === null ? "" : net);
    }

    write_initial_zone_values("net", player, netValues);

}

function show_computed_stb(player) {
    var nb_hole = get_nb_hole();
    var stbValues = [];
    var i;
    for (i = 0; i < nb_hole ; i++) {
        var par = select_par_value(player,i);
        var brut = select_input_value(player, i);
        var recu = select_computed_td_value("recu", player, i);
        var net = get_value_net(brut, recu, i);
        var stb = get_value_stb(par, net, brut);
        $(select_computed_td("stb", player, i)).text(stb)
        stbValues.push(stb === undefined || stb === null ? "" : stb);
    }

    write_initial_zone_values("stb", player, stbValues);
}

function get_value_net(brut, recu, hole) {
    if (!brut && brut !== 0) {
        return "";
    }
    if (brut === "") {
        return "";
    }
    if (brut == 0) {
        return "x";
    }
    if (!recu) {
        recu = 0;
    }
    var net = (brut - recu);

    return net;
}

function get_value_stb(par, net, brut) {
    if (!brut && brut !== 0) {
        return "";
    }
    if (brut === "") {
        return "";
    }
    if (brut == 0) {
        return "x";
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
    show_diff_par(player);
}

function show_diff_par(player) {
    var hasZeroScore = false;
    var playedHoleCount = 0;
    var brutPlayedTotal = 0;
    var parPlayedTotal = 0;

    $(select_all_input(player)).each(function () {
        var rawValue = $(this).val();
        if (rawValue === "" || rawValue === null || rawValue === undefined) {
            return;
        }

        var numericValue = parseInt(rawValue, 10);
        if (isNaN(numericValue)) {
            return;
        }

        if (numericValue === 0) {
            hasZeroScore = true;
            return;
        }

        if (numericValue > 0) {
            var holeIndex = parseInt($(this).attr("hole"), 10);
            playedHoleCount += 1;
            brutPlayedTotal += numericValue;
            parPlayedTotal += select_par_value(player, holeIndex) || 0;
        }
    });

    var parTarget = $(".par_total[player='" + player + "']").first();
    if (parTarget.length > 0) {
        parTarget.text("Par : " + (playedHoleCount > 0 ? parPlayedTotal : ""));
    }

    if (hasZeroScore || playedHoleCount === 0) {
        set_total_if_present("diff_par", player, "N.A.");
        return;
    }

    var diff = brutPlayedTotal - parPlayedTotal;
    var diffDisplay = diff > 0 ? "+" + diff : diff;
    set_total_if_present("diff_par", player, diffDisplay);
}

function show_totaux_brut(zone, player) {
    var nb_hole = get_nb_hole();
    var frontPoints = 0;
    var backPoints = 0;
    var totalPoints = 0;
    var i=0;
    var brut;
    var brut_valid=true;

    $( select_all_input(player) ).each(function(){
        brut = $(this).val();
        if ( brut === "*") {
            brut_valid = false;
            brut = "0";
        }
        if ( brut === "" ) { brut = "0"; }
        if ( !brut ) { brut = "0"; }
        if(i <= 8 ) {
            frontPoints += parseInt(brut);
        } else if (nb_hole > 9) {
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

    set_total_if_present(zone + "_front", player, frontPoints);
    set_total_if_present(zone + "_back", player, backPoints);
    set_total_if_present(zone + "_total", player, totalPoints);

    return true
}

function show_totaux_zone(zone, player) {
    var nb_hole = get_nb_hole();
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
        } else if (nb_hole > 9) {
            backPoints += value;
        }
        i += 1;
    });
    totalPoints += (frontPoints + backPoints);
    if (frontPoints === 0) { frontPoints = "" }
    if (backPoints === 0) { backPoints = "" }
    if (totalPoints === 0) { totalPoints = "" }
    set_total_if_present(zone + "_front", player, frontPoints);
    set_total_if_present(zone + "_back", player, backPoints);
    set_total_if_present(zone + "_total", player, totalPoints);

    return true
}

function write_initial_zone_values(zone, player, values) {
    var input = $(read_initial_zone(zone, player));
    if (input.length === 0) {
        return;
    }
    input.val(values.join(","));
}

function set_total_if_present(selectorClass, player, value) {
    var target = $("."+selectorClass+"[player='"+player+"']");
    if (target.length > 0) {
        target.text(value);
    }
}

function get_nb_hole() {
    return parseInt($("#nb_hole").text(), 10) || 18;
}