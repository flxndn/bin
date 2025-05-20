for i in *.jpg; do b=$(echo $i| cut -f1 -d.); info=$(ls *.json | grep $b | grep -v thumb) t=$(ls *.json| grep $b | grep thumb); cloudinary_get_image_info.py -y $info $t; done  | tee /tmp/kk.yaml
