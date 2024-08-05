      program write_datafile
	  implicit none 
	  
	  double precision, allocatable :: mass(:)
	  
	  double precision :: lx, ly, lz 
	  double precision :: x, y, z, noiseX, noiseY, noiseZ   
	  
      integer, allocatable :: bonds(:,:)
      integer, allocatable :: bondsperatom(:)
      integer, allocatable :: angles(:,:)	  
	  integer, allocatable :: atID(:)	  
	  
      integer :: natom, frame, ncomponent
	  integer :: typeindex, natomtypes
	  integer :: natomincomp, nbond, nangle  
      integer :: index, natommax
      integer :: atA, atB, atC 	  
      integer :: i, j, k, l
	  
      character*2, allocatable :: el(:)
	  
	  character*100 :: foutdata 
	  
!!!!! Set Parameters !!!!!
	
	  call srand(1234)

	  natomtypes	= 4
	  lx	   		= 20.0d0 
	  ly 	   		= 20.0d0 
	  lz 	   		= 20.0d0 	  
	  natommax		= 1000
	  
	  allocate(mass(natomtypes))
	  mass(1) 		= 28.086d0 
	  mass(2)		= 15.999d0
	  mass(3)		= 12.010d0 
	  mass(4)		= 1.0079d0       

!!!!! Get Components !!!!!
	  
	  open(20,file='struct.txt')
	  read(20,*) 
	  read(20,*) 
	  read(20,*)       
	  read(20,*) natom
	  read(20,*)       

	  allocate (el(natommax))
	  allocate (atID(natommax))
      allocate (bonds(natommax,natommax))
      allocate (bondsperatom(natommax))
	  allocate (angles(natommax*natommax,3))

	  do i=1,natom 
	    read(20,*) atID(i), el(atID(i)), bondsperatom(atID(i)), (bonds(atID(i),j),j=1,bondsperatom(atID(i)))
	  enddo 
	  close(20)
	  
!!!!! Write Data Files !!!!!
	  	  
	  !Gather Important Info for Datafile 
	  nbond  = 0
	  nangle = 0 
	  do i=1,natom 
		!Update Bond Count 
		nbond = nbond + bondsperatom(atID(i))
		!Find and Update Angle Count  		
		atA = atID(i) 
		do j=1,bondsperatom(atID(i))
     	  atB = bonds(atID(i),j) 
		  !Go through atoms bonded to AtomB
		  do l=1,bondsperatom( bonds(atID(i),j) )
 		    atC = bonds( bonds(atID(i),j) ,l)
  			if( atC.ne.atA )then 
		      nangle = nangle + 1 
			  angles(nangle,1) = atA 
			  angles(nangle,2) = atB 
			  angles(nangle,3) = atC 				
			endif 
		  enddo  
		enddo 			

	  enddo 
	  
	  !Open Target Datafile
	  foutdata = 'data.pdms'
	  open(30,file=foutdata)		
		
	  !Write Datafile
3000  format(' LAMMPS Input for Backbone')
3001  format(I12,' atoms')		
3002  format(I12,' bonds')	
3003  format(I12,' angles')	
3004  format(I12,' dihedrals')	
3005  format(I12,' impropers')			
3006  format(I12,' atom types')			
3007  format(I12,' bond types')	
3008  format(I12,' angle types')	
3009  format(I12,' dihedral types')	
3010  format(I12,' improper types')			
3011  format(2F20.4,' xlo xhi')		
3012  format(2F20.4,' ylo yhi')	
3013  format(2F20.4,' zlo zhi')	
3014  format(' Masses')
3015  format(I4,F20.6)
3016  format(' Atoms')
3017  format(I12, I10, I4, F4.1, 3F20.4)
3018  format(' Bonds')
3019  format(4I12)
3020  format(' Angles')
3021  format(5I12)

		write(30,3000)
		write(30,*)
		write(30,3001) natom
		write(30,3002) nbond
		write(30,3003) nangle
		write(30,3004) 0
		write(30,3005) 0
		write(30,*)
		write(30,3006) natomtypes  
		write(30,3007) 1 
		write(30,3008) 1 
		write(30,3009) 0 
		write(30,3010) 0 		
		write(30,*)	
		write(30,3011) 0.0d0, lx 
		write(30,3012) 0.0d0, ly 
		write(30,3013) 0.0d0, lz 		
		write(30,*)
		write(30,3014)			
		write(30,*)			
		do i=1,natomtypes 
		  write(30,3015) i, mass(i) 
		enddo 
		write(30,*)	
		write(30,3016) 
		write(30,*)		
		
		x = lx/2.0d0 
		y = ly/2.0d0 
		z = lz/2.0d0 
		
		do i=1,natom 
		    typeindex = -1 
			if(el(atID(i)).eq.'Si') typeindex = 1
			if(el(atID(i)).eq.'O')  typeindex = 2
			if(el(atID(i)).eq.'C')  typeindex = 3
			if(el(atID(i)).eq.'H')  typeindex = 4            
			noiseX = ( rand() - 0.5d0 )*1.0d0 
			noiseY = ( rand() - 0.5d0 )*1.0d0 
			noiseZ = ( rand() - 0.5d0 )*1.0d0 			
			write(30,3017) atID(i), 1, typeindex, 0.0d0, x + noiseX, y + noiseY, z + noiseZ 
		enddo 

		if(nbond.ge.1)then !Write bonds section only if bonds are present
		  index = 0 
		  write(30,*)
		  write(30,3018)
		  write(30,*)
		  do i=1,natom
			  do j=1,bondsperatom(atID(i))
			    index = index + 1
		        write(30,3019) index, 1, atID(i), bonds(atID(i),j) 
			  enddo 
		  enddo 
		endif 
		
		if(nangle.ge.1)then !Write angles section only if angles are present
		  index = 0 
		  write(30,*)
		  write(30,3020)
		  write(30,*)
		  do i=1,nangle
			write(30,3021) i, 1, (angles(i,j),j=1,3)
		  enddo 
		endif 
		
		
		
		!Close Datafile		
		close(30)
		

	  
!!!!! END !!!!!	  

	  end 