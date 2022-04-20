<?php

//oracleTest();
gdTest();


// Oracle 10-12 Test
function oracleTest(){
    $conn = oci_connect('system', 'oracle', '192.168.1.136/XE');
    if (!$conn) {
        $e = oci_error();
        trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
    } else { 
        echo 'succesful';
    }

    $stid = oci_parse($conn, 'SELECT * FROM HELP');
    oci_execute($stid);
    echo "<table border='1'>\n";
    while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
        echo "<tr>\n";
        foreach ($row as $item) {
            echo "    <td>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "") . "</td>\n";
        }
        echo "</tr>\n";
    }
    echo "</table>\n";
}


// GD Test
function gdTest(){
    header("Content-type: image/png");
    $cadena = 'Texto de prueba';
    $im     = imagecreatefrompng("images/boton1.png");
    $naranja = imagecolorallocate($im, 220, 210, 60);
    $px     = intval((imagesx($im) - 7.5 * strlen($cadena)) / 2);
    imagestring($im, 200, $px, 150, $cadena, $naranja);
    imagepng($im);
    imagedestroy($im);
}