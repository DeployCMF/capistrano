echo "Enter the new Drupal Bootstrap(sass) subtheme name to create:"
read dwheel
#Create the subtheme directory in custom folder
mkdir -p themes/custom
cp -r themes/bootstrap/starterkits/sass themes/custom/$dwheel

#Rename the files
mv themes/custom/$dwheel/config/install/THEMENAME.settings.yml themes/custom/$dwheel/config/install/$dwheel.settings.yml
mv themes/custom/$dwheel/config/schema/THEMENAME.schema.yml themes/custom/$dwheel/config/schema/$dwheel.schema.yml
mv themes/custom/$dwheel/THEMENAME.libraries.yml themes/custom/$dwheel/$dwheel.libraries.yml
mv themes/custom/$dwheel/THEMENAME.theme themes/custom/$dwheel/$dwheel.theme
mv themes/custom/$dwheel/THEMENAME.starterkit.yml themes/custom/$dwheel/$dwheel.info.yml

#Editing the file content with search/replace for THEMENAME and THEMETITLE
sed -i "s/THEMENAME/$dwheel/g" themes/custom/$dwheel/config/schema/$dwheel.schema.yml
sed -i "s/THEMETITLE/$dwheel/g" themes/custom/$dwheel/config/schema/$dwheel.schema.yml
sed -i "s/THEMENAME/$dwheel/g" themes/custom/$dwheel/$dwheel.info.yml
sed -i "s/THEMETITLE/$dwheel/g" themes/custom/$dwheel/$dwheel.info.yml

wget -P themes/custom/$dwheel https://github.com/twbs/bootstrap-sass/archive/master.zip
unzip themes/custom/$dwheel/master.zip -d themes/custom/$dwheel/
mv themes/custom/$dwheel/bootstrap-sass-master themes/custom/$dwheel/bootstrap
rm themes/custom/$dwheel/master.zip


#Edit the libraries.yml and rename scss folder to sass
sed -i "s/css\//stylesheets\//g" themes/custom/$dwheel/$dwheel.libraries.yml
mv themes/custom/$dwheel/scss themes/custom/$dwheel/sass


#compil with compass to create stylesheets/style.css file
cd themes/custom/$dwheel
compass compile
