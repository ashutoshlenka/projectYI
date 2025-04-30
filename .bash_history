cd ansible/
mkdir ansible/
cd ansible/
ls
vim provision.yml
cd ..
ls
mkdir nginx
cd nginx/
vim default.conf
cd ..
mkdir src
cd src/
ls 
vim Dockerfile
git clone https://github.com/yiisoft/yii2-app-basic.git src
cd src
composer install
apt install composer
ls
cd src
composer install
cd ..
ls
cd src
composer install
ls
cd ..
vim docker-compose.yml
git init
mkdir .github/
cd .github/
mkdir workflows/
cd workflows/
vim deploy.yml
cd ..
git add .
git commit -m 'commit'
cd src
ls
docker build -t ashutosh1999/yii2-app:latest .
docker push ashutosh1999/yii2-app:latest
docker login
docker images
docker push ashutosh1999/yii2-app:latest
docker service update --image ashutosh1999/yii2-app:latest yii2_app
docker service create --name yii2_app   --publish 8080:80   --replicas 1   ashutosh1999/yii2-app:latest
http://18.212.71.237/
exit
