git init
git add .
git commit -m "Aggiungo i file misteriosi al grimorio"
git remote add origin git@github.com:bonobix/bash-scripts.git
git pull origin main --allow-unrelated-histories  # se serve unire storie diverse
git push -u origin main
