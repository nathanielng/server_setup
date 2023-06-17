<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hello World PHP App</title>
  <style>
    body {
      text-align: center;
      background: rgb(40, 9, 75);
      color: white;
      font-family: helvetica;
    }
  </style>
</head>

<body>
<div class="c1" align="center">
  <h1>This is a PHP Example Web Page</h1>
  <h2><?php
    echo "Hello, world!";
    ?>
  </h2>
</div>

<div class="c2" align="center">
  <p>
    <b>Current Date & Time</b>: <?php
        $weekday = date('l', mktime(0, 0, 0, 4, 1, 2014));
        $now = date("F d, Y h:i:s", time());
        echo($weekday, ', ', $now);
    ?>
  </p>
</div>
<div class="c2" align="center">
  <p><b>Timestamp</b>:
    <?php 
    $timestamp = time();
    echo($timestamp);
    ?>
  </p>
</div>

</body>
</html>
