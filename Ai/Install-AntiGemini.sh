echo """
   ###    ##    ## ######## ####  ######   ######## ##     ## #### ##    ## ####
  ## ##   ###   ##    ##     ##  ##    ##  ##       ###   ###  ##  ###   ##  ##
 ##   ##  ####  ##    ##     ##  ##        ##       #### ####  ##  ####  ##  ##
##     ## ## ## ##    ##     ##  ##   #### ######   ## ### ##  ##  ## ## ##  ##
######### ##  ####    ##     ##  ##    ##  ##       ##     ##  ##  ##  ####  ##
##     ## ##   ###    ##     ##  ##    ##  ##       ##     ##  ##  ##   ###  ##
##     ## ##    ##    ##    ####  ######   ######## ##     ## #### ##    ## ####
 
                    AntiGemini | made by @ZAASHILGLAZA (kvsqqq-ops)
"""
echo ""
echo "Installing ollama..."
yay -S ollama-cuda --noconfirm
echo ""
echo "Installing AntiGemini..."
git clone https://github.com/kvsqqq-ops/AntiGemini.v2
echo ""
echo "Done!"