// Confirmatino log to warn use user existing budget will be deleted

$(function () {

  $("form.create").submit(function (event) {
    event.preventDefault();
    event.stopPropagation();

    var ok = confirm("Creating a new budget will delete your current budget!");
    if (ok) {
      this.submit();
    }
  });

});


