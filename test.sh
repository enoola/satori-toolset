# Tester que Docker fonctionne :
sz_expected_output='Hello from Docker'
ret_dockerrun=$(sudo docker run hello-world | grep "$sz_expected_output")
test -n "$ret_dockerrun" && exit 1 || exit 0
