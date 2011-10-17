<<<<<<< HEAD
// ---------- Schedule Modal

$dashboard_base = "/timesheets/dashboard";

// Setup the dialog
$("#schedule_modal").dialog({ 
  modal: true,
  autoOpen: false,
  width: 500,
  height: 500
});

// open the dialog
$('#schedule_modal_link').click(function() {
  $("#schedule_modal").dialog('open');
  return false;
});

// setup datepicker inside the dialog
$("#scheduled_at").datepicker( {
  onSelect: function(dateText, inst) {
    $("#work_unit_scheduled_at").val(dateText);
    $("#schedule_modal").dialog('close');
    $('#schedule_modal_link').text($('#work_unit_scheduled_at').val());
  },
  dateFormat: 'yy-mm-dd'
});


=======
>>>>>>> d5da26fae896e46d44a16ac4ceb3c8e74f9fa7bd
// ---------- Work Unit Creation

// when client is changed, populate the projects
$("#work_unit_client_id").change(function(){
  var me = $("#work_unit_project_id");
  me.children().remove();
  me.append( new Option("Select a project","") )
  $("#work_unit_ticket_id").children().remove();
  $("#work_unit_ticket_id").append( new Option("Select a ticket",""))
  if(this.value != "") {
    $.get($dashboard_base + "/client", { id: this.value }, function(data){
      $.each(data, function(){
        $.each(this, function(k, v){
          me.append( new Option(v.name, v.id) )
        });
      });
    }, "json");
  }
});

// when project is changed, populate the tickets
$("#work_unit_project_id").change(function(){
  var me = $("#work_unit_ticket_id")
  me.children().remove();
  me.append( new Option("Select a ticket","") )
  if(this.value != "") {
    $.get($dashboard_base + "/project", { id: this.value }, function(data){
      $.each(data, function(){
        $.each(this, function(k, v){
          me.append( new Option(v.name, v.id) )
        });
      });
    }, "json");
  }
});

// AJAX work unit creation
$("#new_work_unit").submit(function() {
  var me = $(this);
  $("#work_unit_submit").attr('disabled', true);
  $.ajax(
  {
    async: true,
    global: false,
    url: me.attr("action"),
    type: "POST",
    dataType: "json",
    data: {"work_unit[description]": me.find("#work_unit_description").val(),
      "work_unit[scheduled_at]": me.find("#work_unit_scheduled_at").val(),
      "work_unit[client_id]": me.find("#work_unit_client_id").val(),
      "work_unit[project_id]": me.find("#work_unit_project_id").val(),
      "work_unit[ticket_id]": me.find("#work_unit_ticket_id").val(),
      "work_unit[hours]": me.find("#work_unit_hours").val(),
      "work_unit[overtime]": me.find("#work_unit_overtime").val(),
      "hours_type": me.find("#hours_type").val()
       },
    success: function(result)
    {
      var notice = result.notice
      me.trigger("reset");
      me.effect("highlight");
      // Ask the calendar to update itself
      update_calendar_block();
      $('#work_unit_scheduled_at').val(new Date());
      $('#scheduled_at').datepicker('setDate', new Date());
      $('#schedule_modal_link').text($('#scheduled_at').val());
      if(notice) {
        $("#work_unit_errors").data('notice', notice);
        $("#work_unit_errors").dialog('open');
      };
      $("#work_unit_submit").attr('disabled', false);
    },
    error: function(result)
    {
      var json_result = JSON.parse(result.responseText);
      var errors = json_result.errors;
      $("#work_unit_errors").data('errors', errors);
      $("#work_unit_errors").dialog('open');
      $("#work_unit_submit").attr('disabled', false);
    }
  });
  return false;
});

// Error handling on failed AJAX work unit creation
$("#work_unit_errors").dialog( {
  autoOpen: false,
  hide: true,
  title: "Notice",
  modal: true,
  draggable: false,
  open: function() {
    var dialog = $("#work_unit_errors");
    dialog.html("");
    if(dialog.data('errors')) {
      dialog.append("<p>" + dialog.data('errors') + "</p>");
    };
    if(dialog.data('notice')) {
      dialog.append("<p>" + dialog.data('notice') + "</p>")
    };
  },
  close: function() {
    var dialog = $("#work_unit_errors")
    dialog.html("");
  }
});

// ---------- Ticket Creation

// when client is changed, populate the projects
$("#ticket_client_id").change(function(){
  var me = $("#ticket_project_id");
  me.children().remove();
  me.append( new Option("Select a project","") )
  $("#work_unit_ticket_id").children().remove();
  $("#work_unit_ticket_id").append( new Option("Select a ticket",""))
  if(this.value != "") {
    $.get($dashboard_base + "/client", { id: this.value }, function(data){
      $.each(data, function(){
        $.each(this, function(k, v){
          me.append( new Option(v.name, v.id) )
        });
      });
    }, "json");
  }
});

// when project is changed, populate the tickets
$("#ticket_project_id").change(function(){
  var me = $("#ticket_ticket_id")
  me.children().remove();
  me.append( new Option("Select a ticket","") )
  if(this.value != "") {
    $.get($dashboard_base + "/project", { id: this.value }, function(data){
      $.each(data, function(){
        $.each(this, function(k, v){
          me.append( new Option(v.name, v.id) )
        });
      });
    }, "json");
  }
});

// AJAX ticket creation
$("#new_ticket").submit(function() {
  var me = $(this);
  $("#ticket_submit").attr('disabled', true);
  $.ajax(
  {
    async: true,
    global: false,
    url: me.attr("action"),
    type: "POST",
    dataType: "json",
    data: {"ticket[project_id]": me.find("#ticket_project_id").val(),
      "ticket[name]": me.find("#ticket_name").val(),
      "ticket[description]": me.find("#ticket_description").val() },
    success: function(result)
    {
      var json = $.parseJSON( result.responseText )
      me.trigger("reset");
      me.effect("highlight");
      $("#ticket_submit").attr('disabled', false);
    },
    error: function(result)
    {
      var json = $.parseJSON( result.responseText )
      $("#ticket_errors").data('errors', json);
      $("#ticket_errors").dialog('open');
      $("#ticket_submit").attr('disabled', false);
    }
  });
  return false;
});

// Error handling on failed AJAX ticket creation
$("#ticket_errors").dialog( {
  autoOpen: false,
  hide: true,
  title: "Error",
  modal: true,
  draggable: false,
  open: function() {
    var dialog = $("#ticket_errors")
    dialog.html("")
    $.each( dialog.data('errors'), function() {
      dialog.append("<p>" + this + "</p>")
    });
  },
  close: function() {
    var dialog = $("#ticket_errors")
    dialog.html("");
  }
});


// ---------- Schedule Modal
function update_calendar_block(){
  $.ajax( {
    async: true,
    url: '/dashboard/calendar',
    type: 'GET',
    dataType: 'script'
  });
}

// ---------- Calendar Javascript
function get_week(week){
  $.ajax( {
    async: true,
    url: '/dashboard/update_calendar?date=' + week,
    type: 'GET',
    dataType: 'json',
    success: function(response){
      $('.calendar').html(response.data);
      $('.week_pagination').html(response.week_pagination);
      // We have to reload the triggers since they are regenerated on each request
      set_week_pagination_triggers();
    }
  });
}

function set_week_pagination_triggers(){
  $('.get_week_calendar').click(function(e){
    var week = /\d{4}-\d{2}-\d{2}/i.exec(this);
    get_week(week);
    return false;
  });
}

set_week_pagination_triggers();
