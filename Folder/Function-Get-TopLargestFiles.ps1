Function Get-TopLargestFiles
{
    <#
.SYNOPSIS
    Get-TopLargestFiles recherche de mani?re r�cursive dans un path donn�, et retourne les X plus gros fichiers

.DESCRIPTION
    Get-TopLargestFiles recherche de mani?re r�cursive dans un path donn�, et retourne les X plus gros fichiers

    Accepte les paths multiples

.INPUTS
   Accepte les Paths en prvenance du pipeline

.OUTPUTS
   Sortie de cette applet de commande (le cas échéant)

.EXAMPLE
    Get-TopLargestFiles -Path c:\temp

    Retourne les 10 plus gros fichiers du r�pertoire c:\temp

.EXAMPLE
    Get-TopLargestFiles -Path c:\temp, c:\temp2 -top 5
    Retourne les 5 plus gros fichiers du r�pertoire de c:\temp et c:\temp2


.NOTES
  Version         :  1.0
  Author          : O. FERRIERE
  Creation Date   : 17/01/2018
  Purpose/Change  : Développement initial du script
#>

    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # Aide sur Param?tre $Path
        [Parameter(
            ValueFromPipeline = $True, # Accepte les entr�es depuis le pipeline
            ValueFromPipelineByPropertyName = $True, # Accepte les entr�es depuis le pipeline par nom
            Mandatory = $True, # obligatoire
            HelpMessage = "Entrer le path du r�pertoire cible"          # message d'aide
        )]
        [ValidateScript( {Test-Path $_})]                               # Validation du path. Si n'existe pas, stop.
        [String[]]$Path,

        # Aide sur le param?tre $Unit
        [Parameter(
            HelpMessage = "Param�trer l'unit� de mesure de la fonction. Le D�faut est en GB (Go en fran?ais), Les valeurs acceptables sont KB, MB, GB")]
        [ValidateSet('KB', 'MB', 'GB')]                             # Jeu de validation des unités. Si pas dans le jeu ==> arrêt
        [String]$Unit = 'GB',


        # Aide sur le param?tre $Top
        [Parameter(
            HelpMessage = "Nombre de plus gros fichiers ? retourner. le D�faut est 10")]
        [Int]$Top = "10"


    ) # End param

    Begin
    {
        # Transformation de l'unit� saisie en param?tre pour l'affichage de la taille
        Write-Verbose "Param�trage de l'unit� de mesure"
        $value = Switch ($Unit)
        {
            'KB'
            {
                1KB
            }
            'MB'
            {
                1MB
            }
            'GB'
            {
                1GB
            }
        }
    } # End Begin

    Process
    {
        # On entre dans une boucle foreach, pour le cas ou plusieurs paths on �t� saisies.
        Foreach ($FilePath in $Path)
        {
            Try
            {
                Write-Verbose "R�cup�ration de la taille des r�pertoires"
                # On essaie de calculer la taille de l'arborescence en cours de traitement, et si pb on arr?te
                $Files = Get-ChildItem $FilePath -Recurse -Force -ErrorAction Stop |
                    Sort-Object -Descending -Property Length
            }
            Catch
            {
                # En cas d'erreur , on trappe l'erreur et on passe la variable $Probleme ? $True
                Write-Warning $_.Exception.Message
                $Probleme = $True
            }

            If (-not ($Probleme))
            {
                # On est dans le cas ou $Probleme n'est pas �gal ? $True
                Try
                {
                    # Essai de sortie en console du TOP des fichiers
                    Write-Verbose "Sortie en console du TOP des fichiers"
                    Write-Output $FilePath
                    $TopFilesName = $Files | Select-First $Top -ErrorAction Stop |
                        Select-Object -Property `
                    @{Label = "Nom Complet"   ; Expression = {$_.FullName }},
                    @{Label = "$Unit"         ; Expression = {"{0:N2}" -f ($_.Length / $value) }}
                    Write-Output $TopFilesName
                }

                Catch
                {
                    # En cas d'erreur du Try, on attrape l'erreur
                    Write-Warning $_.Exception.Message
                    $Probleme = $True
                }

            } # end du if

            if ($Probleme)
            {
                # R�initialisation de $Probleme pour l'arborescence suivante ? traiter dans la boucle foreach
                $Probleme = $false
            }

        }  # end du foreach
    } # End du Process

    End
    {
        Write-Verbose "Fin du traitement de l'arborescence en cours"
    } # End du End
} # End de la fonction
