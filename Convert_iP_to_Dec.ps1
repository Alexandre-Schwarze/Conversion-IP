# déclare nom du serveur
$Server = "JUPITER\CARNOFLUXE"
#déclare nom de la base de données
$Database = "carnofluxe"
#déclare la 1ère requête
$Query = "SELECT ID_IP,IP FROM IP_Apache.IP_Apache WHERE pays IS NULL"

# Fonction de connexion + requête au serveur et à la base de donnée # 
function SqlExec( $Server, $Database, $Query ){
 #initialise un objet de connexion SQL
 $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
 # initialise la méthode d'information de connexion au serveur SQL
 $SqlConnection.ConnectionString = "Server = $Server; Database = $Database; Integrated Security = True"
 # lance la connexion
 $SqlConnection.Open()
#initialise un objet de commande SQL
 $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
 #renseigne la méthode de requête SQL 
 $SqlCmd.CommandText = $Query
 #renseigne la méthode contenant les informations de connexion
 $SqlCmd.Connection = $SqlConnection

 #déclare un objet SqlDataAdapter permettant de remplir un DataSet
 $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
 #initilaise l'objet SqlAdapter avec l'objet de connexion SQL
 $SqlAdapter.SelectCommand = $SqlCmd
#Déclare un objet DataSet
 $DataSet = New-Object System.Data.DataSet
 # "remplit" l'objet DataSet avec les données renvoyées par le SqlDataAdapter 
 $SqlAdapter.Fill($DataSet)
 # retire les données nulles
 $SqlAdapter | Out-Null
#ferme la connexion SQL
 $SqlConnection.Close()
 
#renvoie le DataSet récupéré
 return $DataSet

}
# Déclaration de la fonction Conversion IP en Decimal
function convertIpToDecimal($Ip)
{
     #Déclare le facteur de la puissance sur le nombre d'octets -1
     $puissance = $Ip.Count-1
     #Initialise variable $ValeurDécimale à 0
     $valDec = 0
     #boucle qui parcourt chaque octet 
     for($j=0 ; $j -lt $Ip.Count ; $j++)
     {  # BOucle qui effectue son instruction si la variable n'est pas égale à 0
        if($puissance -ne 0)
        {   #instruction qui ajoute à $ValDec la valeur de l'octet multiplié par 256^$puissance
            $valDec = $valDec + [MATH]::Pow(256 , $puissance)*$Ip[$j]
        }
        else
        {   #instruction qui additionne à $ValDec la valeur numérique de l'octet
            $valDec = $valDec + $Ip[$j]
        }
        #Décrémente la variable $puissance
        $puissance--;
     }  
    #Retourne la $ValeurDécimale de l'IP donnée en paramètre
    return $valDec
}

#exécute la connexion avec requête sur le serveur SQL
$data = SqlExec -Server $Server -Database $Database -Query $Query

# Déclare tableau/array destiné à stocker les futurs résultats x2
$valDec = @()
$ipdec = @()
#BOucle qui parcourt chaque ligne de la 1ère table renvoyée
for($i=0 ; $i -lt $data.Tables[0].Rows.Count ; $i++)
     # initialise dynamiquement la taille de l'index de l'array X2
{    $valDec += @($i)
     $ipdec += @($i)
     #Déclare variable prenant en valeur la chaine découpée
     $valT = $data.Tables[0].Rows[$i]['IP'].split('.')
     # ajoute chaque ID_IP à index $i de l'array
     $ipdec[$i] = $data.Tables[0].Rows[$i]['ID_IP']
     # Appelle la fonction de conversion en décimal et insère la valeur retournée dans l'index $i de l'array
     $valDec[$i] = convertIpToDecimal($valT)        
}


#boucle itérant sur la valeur de l'index du tableau de donnée contenant les ip décimales
for($i=0 ; $i -lt $valDec.Count ; $i++)
{
#assigne chaque ip décimale contenue dans le tableau à une variable
$val = $valDec[$i]
#assigne chaque ID des IP traitées contenues dans le tableau à une variable
$id = $ipdec[$i]
# déclare une nouvelle requête d'insertion dans la base avec les données determinées en variables
$query = "UPDATE IP_Apache.IP_Apache SET IP_dec = $val WHERE ID_IP = $id"
#exécute la connexion et la requête
$data = SqlExec -Server $Server -Database $Database -Query $Query
}

