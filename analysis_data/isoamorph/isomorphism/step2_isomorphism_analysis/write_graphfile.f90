      program write_datafile
	  implicit none 
	  
      integer, allocatable :: bonds(:,:)
      integer, allocatable :: bondsperatom(:)  
      integer, allocatable :: compID(:)
	  
      integer :: natom, frame, ncomponent
	  integer :: natomincomp, nbondincomp, nangleincomp  
      integer :: index, component
      integer :: atA, atB, atC 	  
      integer :: i, j, k, l
	  
      character*2, allocatable :: el(:)
	  
	  character*100 :: foutdata 
	  

!!!!! Get Components !!!!!
	  
	  open(20,file='frame.txt')
	  read(20,*) natom, frame, ncomponent 
	  
	  allocate (el(natom))
	  allocate (compID(natom))
      allocate (bonds(natom,natom))
      allocate (bondsperatom(natom))
	  
	  read(20,*) 
	  do i=1,natom 
	    read(20,*) index, el(i), compID(i), bondsperatom(i), (bonds(i,j),j=1,bondsperatom(i))
	  enddo 
	  close(20)
	  
!!!!! Write Individual Data Files !!!!!
	  
	  do component=1,ncomponent
	  
		!Gather Important Info for Graph File 
		natomincomp  = 0 
		nbondincomp  = 0
		nangleincomp = 0 
		do i=1,natom 
		  if(compID(i).eq.component)then
			!Update Atom Count 
		    natomincomp = natomincomp + 1
			!Update Bond Count 
			nbondincomp = nbondincomp + bondsperatom(i)
			!Find and Update Angle Count  		
			atA = i 
			do j=1,bondsperatom(i)
			  atB = bonds(i,j) 
			  !Go through atoms bonded to AtomB
			  do l=1,bondsperatom( bonds(i,j) )
			    atC = bonds( bonds(i,j) ,l)
			    if( atC.ne.i )then 
			      nangleincomp = nangleincomp + 1 	
			    endif 
			  enddo  
			enddo 			
		  endif 
		enddo 
	  
		!Open Target Datafile
	    if(component.ge.1   .and. component.lt.10)   write(foutdata,9001) component
	    if(component.ge.10  .and. component.lt.100)  write(foutdata,9002) component
	    if(component.ge.100 .and. component.lt.1000) write(foutdata,9003) component		
9001	format('graph.',I1,'.txt')	
9002	format('graph.',I2,'.txt')	
9003	format('graph.',I3,'.txt')
	    open(30,file=foutdata)		
		
	    !Write Graph File
		
3000	format('#FRAME COMPONENT')
3001	format(2I12)
3002    format('#DESCRIPTOR')		
3003    format(3I12)
3004    format('#ID EL NBONDS BONDED_IDS')
3005    format(I12,A4,99I12)		
		
		write(30,3000) 
		write(30,3001) frame, component 
		write(30,3002)
		write(30,3003) natomincomp, nbondincomp, nangleincomp
		write(30,3004) 
		do i=1,natom 
		  if(compID(i).eq.component)then
		    write(30,3005) i, el(i), bondsperatom(i), (bonds(i,j),j=1,bondsperatom(i))
		  endif 
		enddo 
		
		!Close Graph File		
		close(30)
		
	  enddo 
	  
!!!!! END !!!!!	  

	  end 