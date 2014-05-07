param (
	[string]$root_dir = $(throw "Usage: .\bootstrap.ps1 root_dir")
)

function CreateNewKey {
	$client = new-object System.Net.WebClient;
	$post_body = new-object Collections.Specialized.NameValueCollection;
	$post_body.Add("key_id", $args[0]);
	$result = $client.UploadValues("http://localhost:8787/proxy/8000/8888/key/", "POST", $post_body);
}

# Killall node.js processes because we're mean like that.  If there's no
# node process, cool.
Stop-Process -processname node -erroraction 'silentlycontinue'

Start-Process -NoNewWindow -Wait npm install
Start-Process -NoNewWindow -Wait -WorkingDirectory test\key_server\ npm install

# Fixup path to be node-friendlier.
$root_dir = $root_dir.Replace("\", "\\")
"Creating config in $root_dir"

Set-Content -Value "{ `"root_dir`": `"$root_dir`" }" -Path config.json

New-Item -ItemType directory -Path $root_dir\8000\8888 -erroraction 'silentlycontinue'

Start-Process -NoNewWindow node auspice.js
Start-Process -NoNewWindow -WorkingDirectory test\key_server\ node key_server.js

"Waiting 5 seconds for servers to come online."

Start-Sleep 5

CreateNewKey "bash-test-key"
CreateNewKey "perl-test-key"
CreateNewKey "python-test-key"
CreateNewKey "powershell-test-key"
CreateNewKey "ruby-test-key"
CreateNewKey "java-test-key"
CreateNewKey "dotnet-test-key"
CreateNewKey "node-test-key"

Start-Process -NoNewWindow -Wait -WorkingDirectory test\server\ npm install
Start-Process -Wait -NoNewWindow -WorkingDirectory test\server\ node job_server.js