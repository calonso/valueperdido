# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all

u = User.create!(:name => "Carlos", :surname => "Alonso", :email => "mrcalonsoperez@gmail.com", :admin => true,
            :validated => true, :encrypted_password => "a20cd4e084edc003ec387eca1133790d37d9d904e86a739f3973dcfbf9109f06",
            :salt => "6d86db1dd5ca55da03046dbf121f639ebd05192518752a47af02633673eac27d", :passive => false)
p = u.payments.create!(:amount => 76.66)
p.recalculate_percentages

u = User.create!(:name => "Deivid", :surname => "Perez Perez", :email => "deivitone@gmail.com", :admin => false,
            :validated => true, :encrypted_password => "a8f3a9fc10f83b080076766b9c6bb7dd39f9f92dc19fd00116d8c0c01cfdbded",
            :salt => "15d4654fe684cc77f04fe2cefb54108065a096c7b2d539322320202e4290aba3", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Javier", :surname => "Sanchez", :email => "chimvo@gmail.com", :admin => true,
            :validated => true, :encrypted_password => "e2c3c978c93eb6b00e06e826c33d42b500b2203cef51e894f05aabbcdeeb1994",
            :salt => "bdfb0f786246a87767d27ad682a040592a635b3af9aebd76482469419547788f", :passive => false)
p = u.payments.create!(:amount => 78.66)
p.recalculate_percentages

u = User.create!(:name => "Rodrigo", :surname => "Martin", :email => "romartinmontes@gmail.com", :admin => false,
            :validated => true, :encrypted_password => "e8aca5156182c4a73c02a972da358015bafa80e9f9e4c1e7e75c82e8e4ee884b",
            :salt => "1c402e0ee535f9fea131382ccf22c79dd3ef60175b977923f310c6f039847d65", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "...", :surname => "Jody", :email => "j_aguadero@yahoo.es", :admin => false,
            :validated => true, :encrypted_password => "db0ebd50c7337744a055d4bda192954182328c4d963c00d0f793be8570772601",
            :salt => "51ae8c2506234e72c4b10759025db90a0bf2d89f5550c2aedba04770ac3cad0b", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Matias", :surname => "Hopson", :email => "mhefite@hotmail.es", :admin => false,
            :validated => true, :encrypted_password => "63cfcf86cf71324108d075104c5dc062563558c0502f8452a18b1b434411cda3",
            :salt => "b7656887f47c680aa20d9f80e2abce1c4ad2f5cf50f5b380d3a96fc49ff699d8", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Jaime", :surname => "Floujo", :email => "jaimerodrigarcia@gmail.com", :admin => false,
            :validated => true, :encrypted_password => "cb4829907d10dfd8801e43ad784b18364dedbaf07f72cf8dfccf68deca2cbec8",
            :salt => "0d86889110ec308d46ef0a3fb0176591bf9056ccf1b634760b1b484bff0bee60", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Ignacio", :surname => "Moreta", :email => "moretajr@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "6a026c6eeaaa27ba25a560bd86756010ff4b9471bf3a81205c2bd29991c119bc",
            :salt => "a6e25654b0dca2bec40a24ad590d64a34f699632dcd1ee03175b7bea6e2d10a2", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Gonzalo", :surname => "Perez", :email => "gonzalosinverguenza@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "6c5b9417dddc4c15bddddde5d7e8145b30c9b4b357cc643d49aa12c20d139bd5",
            :salt => "8ce54147e903a99d574c0842fde5ff91365b41b0cdffbcb110057e36e34c57be", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Vichuuuu", :surname => "Vichuuuu", :email => "Sese84@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "fbab92c894f572251793e1f515520a45f428d9bb7d93efb2a7f4bd45641ccf6c",
            :salt => "e571c1c76635d9ad8cbe92b35097f027237dc40de4c96b06fd9ea92fa2b2d30f", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Luciano", :surname => "Muriel", :email => "lucianomuriel@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "feb0faf6f77155c6f9225038d247b7571dc4470b9988510bb209467d76e6b528",
            :salt => "745fcc33a0a7b698a35940f5bf77af1d42d96a43fbf9414efc830065c88923e9", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Javier", :surname => "de Santiago", :email => "cabelyo@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "b5b4d14602875c1bde51cd992ccb7ec156a64be1a7c355262c5da5fb657a67e0",
            :salt => "cdfb4d02f236309ecba53758b6222834c87588709f7b5a3a8b9b5dcd000cf7fc", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "jaime", :surname => "hernandez bueno", :email => "jaimehba53@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "8702c2808c470ac9d25290ffefb89173a10628f126cfa5bb1514e093ec6f337b",
            :salt => "97168865d68363961ab5c9da00fa14f1ff1770c5e4f7663579b159582be7bd1d", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "David", :surname => "Martin", :email => "david1083@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "b522433f3be9d6d50f1896ec4fe2cce10abb4b5329a139bc563e217a1502221b",
            :salt => "74e735ecc55870846d25318d53a5303d6db0d437cd38296b231bc23e09706e17", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Alvaro", :surname => "Perez Perez", :email => "kokeepp@gmail.com", :admin => false,
            :validated => true, :encrypted_password => "4cf9dcd1d0f35261f66ba5b777fd4ba2455a9acaac93715d8dd5dc6672e78007",
            :salt => "dc930ed5c76bc26877060a21bfa9069be958e85a32b309a3a016c4e0cc235b8f", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Alberto", :surname => "Baza", :email => "antonitolay@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "fdb1f8709c88a22bd8fe3dd4c538edc8eba117d85399c4968a0d56ae2b650043",
            :salt => "eea2bd523b8504b6f806399daa5dc80287f455f3f023b0da06c166e1eb6798cf", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "DANIEL", :surname => "ROMERO", :email => "dani_romero11@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "abfd529dff394814150e919ba13419e65fb65513c141750d2811b4dd97260a6a",
            :salt => "ceef7986c190762a4b649605651bb466d4ded1d07e885f39d383a44c4d9fa44b", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Bruno", :surname => "Contreras", :email => "contreraschicote@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "d2f677b81106a38b9028ae24d6aad88ebebeb767e7e58fa4ce71430aab5a9d72",
            :salt => "b68430d2e50c50efacd85529bd4b999f65bdfc3c92624c8686fcf343d94db120", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Cesar", :surname => "Torrejon", :email => "ctorrejon@gmail.com", :admin => false,
            :validated => true, :encrypted_password => "1610ac85c2e3c96aabba01f7412dcb582c2d057b92529606c1983706f8b4138c",
            :salt => "9e3efdf837772126990a5bc9c39e74cac5c4f101a0d15d913239f4c0b6890e65", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Jose", :surname => "Perez Albarran", :email => "joseperezalbarran@hotmail.es", :admin => false,
            :validated => true, :encrypted_password => "5f44d693a5efb21d76e605733d21147ae5a89b76127c2b78c3a5322d222561be",
            :salt => "bc90bc0b57e6f7bcc8cb0a2ec0cb085d3686e2461840ff89e60ec1c6a032c252", :passive => true)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "ramon", :surname => "avila", :email => "pive_alaraz@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "669fa49c3fd822cbef48364c294adea3c1323df9a19f66e1d321bd2cdd298feb",
            :salt => "fe96399f1fb76b4143c3fb19842bb9abf054d1e74f1218099b9273975ff853f9", :passive => false)
p = u.payments.create!(:amount => 38.33)
p.recalculate_percentages

u = User.create!(:name => "Manuel Antonio", :surname => "Reyes Canizal", :email => "manuelantonioreyes@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "66fde38a627d0b5fac24f6f9b21a665c2d78c65666753056486218eee63299c9",
            :salt => "44caba97de02f25c67909ee1e830deb3fa0629fed997362cefdb9bc1af90c021", :passive => false)
p = u.payments.create!(:amount => 41.26)
p.recalculate_percentages

u = User.create!(:name => "Hervas", :surname => "Ciprian", :email => "danillo61@hotmail.com", :admin => false,
            :validated => true, :encrypted_password => "37c35bc0dbe40623f02f63730ab66dd7a81ec4e5d0e5e473a038550d5ddd3c1d",
            :salt => "78c20cd0f4764d4c10382f3a06527213da87c72d54af1dfa4b687fa835b21be0", :passive => false)
p = u.payments.create!(:amount => 33.62)
p.recalculate_percentages

u = User.create!(:name => "Paco", :surname => "Kuinkler", :email => "pacoiglesiasgil@gmail.com", :admin => false,
            :validated => true, :encrypted_password => "f2d80df7c6e7935b0078fb6cd9d4b196494cfb723c8394a6500761f30fda28f1",
            :salt => "6917ce9d98efd616d31c25a0f85ead1391cf28e4f41512c595fa86d0dc3ad857", :passive => false)
p = u.payments.create!(:amount => 45.31)
p.recalculate_percentages

