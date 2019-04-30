#!/bin/bash
yum install  zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel  zlib   -y

wget https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tgz
tar -xf Python-2.7.15.tgz
cd Python-2.7.15
./configure --prefix=/usr/local/python2.7 &&  make && make install&& echo "OK"
cd ..
ln -sv /usr/local/python2.7/bin/python2.7 /usr/bin/python2.7
rm -f Python-2.7.15

wget https://files.pythonhosted.org/packages/1a/04/d6f1159feaccdfc508517dba1929eb93a2854de729fa68da9d5c6b48fa00/setuptools-39.2.0.zip
unzip setuptools-39.2.0.zip
cd setuptools-39.2.0
python2.7 setup.py install --prefix=/usr/local/python2.7
cd ..
rm -f setuptools-39.2.0.zip

wget https://files.pythonhosted.org/packages/ae/e8/2340d46ecadb1692a1e455f13f75e596d4eab3d11a57446f08259dee8f02/pip-10.0.1.tar.gz
tar -xvf pip-10.0.1.tar.gz
cd pip-10.0.1
python2.7 setup.py install --prefix=/usr/local/python2.7
ln -sv /usr/local/python2.7/bin/pip /usr/bin/pip2.7
rm -f pip-10.0.1.tar.gz

pip2.7 install virtualenv 
ln -sv /usr/local/python2.7/bin/virtualenv  /usr/bin/virtualenv 
cd /opt
virtualenv --no-site-packages venv
source venv/bin/activate
pip install coscmd
cat >/root/.cos.conf <<EOF
[common]
secret_id = AKI*****
secret_key = mK******
bucket = *****-1234567
region = ap-shanghai
max_thread = 5
part_size = 1
schema = https
EOF
