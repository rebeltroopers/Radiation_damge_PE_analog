      program compute_descriptors
      implicit none

      integer, allocatable :: cID(:)
      integer, allocatable :: bonds(:,:)
      integer, allocatable :: bondsperatom(:)

      integer, allocatable :: cSize(:)
      integer, allocatable :: cComposition(:,:)
      integer, allocatable :: cBondcount(:,:,:)
	  integer, allocatable :: cAnglecount(:,:,:,:)

      integer, allocatable :: descriptor(:)
      integer, allocatable :: uniqueDescriptor(:,:)
      integer, allocatable :: uniqueCount(:)

      integer :: natom, ntype, ncomponent, nangletype 
      integer :: nunique, descriptorsize, maxdescriptors
      integer :: startframe, endframe, frame
      integer :: index, globalIndex
      integer :: attypeA, attypeB, attypeC, atA, atB, atC 
      integer :: uniquecheck, descriptorcheck, descriptorindex
      integer :: i, j, k, l

      character*2, allocatable :: typelist(:)
      character*2, allocatable :: el(:)
      character*100 :: fout
	  
!!!!! Get Parameters !!!!!

      maxdescriptors = 10000

      !Get frame info
      open(20,file='control.txt')
      read(20,*) startframe, endframe
      close(20)

      !Get atom types
      open(20,file='bond_defs.txt')
      read(20,*)
      read(20,*) ntype

      allocate (typelist(ntype))

      read(20,*)
      do i=1,ntype
        read(20,*) index, typelist(index)
      enddo
      close(20)

	  nangletype = 0 
	  do i=1,ntype 
	    do j=1,ntype 
		  do k=i,ntype 
		    nangletype = nangletype + 1 
			!write(*,*) nangletype, i, j, k 
		  enddo 
		enddo 
	  enddo 

      descriptorsize = 1 + ntype + ntype*(ntype+1)/2 + nangletype 

      !Get natom
      open(21,file='components.txt')
      read(21,*) natom
      rewind(21)

!!!!! Allocate Working Arrays !!!!!

      allocate ( el(natom) )
      allocate ( cID(natom) )
      allocate ( bondsperatom(natom) )
      allocate ( bonds(natom,natom) )

      allocate ( cSize(natom) )
      allocate ( cComposition(natom,ntype) )
      allocate ( cBondcount(natom,ntype,ntype) )
	  allocate ( cAnglecount(natom,ntype,ntype,ntype) )

      allocate ( descriptor(descriptorsize) )
      allocate ( uniqueDescriptor(maxdescriptors,descriptorsize) )
      allocate ( uniqueCount(maxdescriptors) )

!!!!! Get Components !!!!!

      open(30,file='descriptors.txt')
      write(30,3000)
3000  format('#GLOBALINDEX  FRAME  COMPONENT  DESCRIPTORINDEX  DESCRIPTOR')

      open(31,file='sorted_components.txt')

      globalIndex   = 0
      nunique       = 0
      uniqueCount   = 0

      do frame=startframe,endframe

        !!!!! Get Bonding Information !!!!!
        read(21,*) index, index, ncomponent
        read(21,*)

        do i=1,natom
          read(21,*) index, el(index), cID(index), bondsperatom(index), &
                     (bonds(index,j),j=1,bondsperatom(index))
        enddo

        !!!!! Compute Basic Descriptors !!!!!
        cSize = 0
        cComposition = 0
        cBondcount = 0
		cAnglecount = 0 
        do i=1,natom

          !Update Size
          cSize(cID(i)) = cSize(cID(i)) + 1

          !Update Composition
          do j=1,ntype
            if( el(i).eq.typelist(j) ) attypeA = j
          enddo
          cComposition(cID(i),attypeA) = cComposition(cID(i),attypeA) + 1

          !Update Bondcounts
          do j=1,bondsperatom(i)
            !Get Atom Type Index
            do k=1,ntype
              if( el( bonds(i,j) ).eq.typelist(k) ) attypeB = k
            enddo
			cBondcount(cID(i),attypeA,attypeB) = cBondcount(cID(i),attypeA,attypeB) + 1 
          enddo


          !Update Anglecounts
		  atA = i
          do j=1,bondsperatom(i)
		  
		    atB = bonds(i,j)
		  
            !Get AtomB Type Index
            do k=1,ntype
              if( el( atB ).eq.typelist(k) ) attypeB = k
            enddo
			
			!Go through atoms bonded to AtomB
			do l=1,bondsperatom( bonds(i,j) )
	
			  atC = bonds( bonds(i,j) ,l)
	
			  if( atC.ne.i )then 
	
			    !Get AtomB Type Index
                do k=1,ntype
                  if( el( atC ).eq.typelist(k) ) attypeC = k
                enddo
			
                cAnglecount(cID(i),attypeA,attypeB,attypeC) = cAnglecount(cID(i),attypeA,attypeB,attypeC) + 1
				!cAnglecount(cID(i),attypeC,attypeB,attypeA) = cAnglecount(cID(i),attypeC,attypeB,attypeA) + 1
			
				!if( cID(i).eq.2 ) write(*,*) atA, atB, atC, attypeA, attypeB, attypeC
			
			  endif 
			
			enddo
			
          enddo

        enddo

		!!!!! Clean up Bond and Angle Counts for double counting !!!!!
		do i=1,ncomponent 
		
		  !Bonds of typeJ=typeK were double counted, but typeJ=/=typeK were not
		  !Make sure all are double counted now and then divide through by 2 
		  do j=1,ntype
            do k=j,ntype	
		      if(j.ne.k) cBondcount(i,j,k) = cBondcount(i,j,k) + cBondcount(i,k,j)
			  cBondcount(i,j,k) = cBondcount(i,j,k)/2 
			enddo 
		  enddo 
		
		  do j=1,ntype 
		    do k=1,ntype 
			  do l=j,ntype

				!Angles of typeJ=typeL were counted twice above
				if(j.eq.l) cAnglecount(i,j,k,l) = cAnglecount(i,j,k,l)/2 
				
			  enddo 
			enddo 
		  enddo 
		
		enddo 



        !!!!! Process and Print Descriptor Information !!!!!
        do i=1,ncomponent

          !Package Descriptor
          index = 1
          descriptor(index) = cSize(i)  !Size
          do j=1,ntype                  !Composition
            index = index + 1
            descriptor(index) = cComposition(i,j)
          enddo
          do j=1,ntype
            do k=j,ntype
              index = index + 1
			  descriptor(index) = cBondcount(i,j,k)
            enddo
          enddo
		  do j=1,ntype 
		    do k=1,ntype 
			  do l=j,ntype 
			    index = index + 1 
				descriptor(index) = cAnglecount(i,j,k,l) 
			  enddo 
			enddo 
		  enddo 

          !Identify Unique Descriptors
          if( frame.eq.startframe .and. i.eq.1)then
            !If first frame and component, start the record
            nunique = 1
            do j=1,descriptorsize
              uniqueDescriptor(nunique,j) = descriptor(j)
            enddo
            descriptorindex = 1
          else

            !Check if current descriptor is unique or matches older one
            uniquecheck = 0
            do j=1,nunique
             if(uniquecheck.ne.1)then
              descriptorcheck = 0
              do k=1,descriptorsize
                if( descriptor(k).eq.uniqueDescriptor(j,k) ) descriptorcheck = descriptorcheck + 1
              enddo
              if(descriptorcheck.eq.descriptorsize)then !not unique, matches old descriptor
                uniquecheck = 1
                descriptorindex = j
              endif
             endif
            enddo

            if(uniquecheck.eq.0)then !found new unique descriptor
              nunique = nunique + 1
              do j=1,descriptorsize
                uniqueDescriptor(nunique,j) = descriptor(j)
              enddo
              descriptorindex = nunique
            endif

          endif

          !!!!! Update Count Per Descriptor Type !!!!!
          uniqueCount(descriptorindex) = uniqueCount(descriptorindex) + 1

          !!!!! Update Master Descriptor File !!!!!
          write(30,3001) globalIndex, frame, i, descriptorindex, (descriptor(j),j=1,descriptorsize)
3001      format(4I12,99I6)

          !!!!! Update sorted_components.txt !!!!!
          write(31,3100)
          write(31,3101) globalIndex, frame, i, descriptorindex
          write(31,3102)
          write(31,3103) (descriptor(j),j=1,descriptorsize)
          write(31,3104)

3100      format('#GLOBALINDEX  FRAME  COMPONENT  DESCRIPTORINDEX')
3101      format(4I12)
3102      format('#DESCRIPTOR')
3103      format(99I6)
3104      format('#ID EL NBONDS BONDED_IDS ')

          do j=1,natom
            if( cID(j).eq.i )then
              write(31,3105) j, el(j), bondsperatom(j), &
                             (bonds(j,k),k=1,bondsperatom(j))
3105          format(I8,A4,I8,99I8)
            endif
          enddo

          !!!!! Print individual structure file for type descriptorindex !!!!!
		  if(descriptorindex.ge.0     .and. descriptorindex.lt.10)     write(fout,9201) descriptorindex
		  if(descriptorindex.ge.10    .and. descriptorindex.lt.100)    write(fout,9202) descriptorindex
		  if(descriptorindex.ge.100   .and. descriptorindex.lt.1000)   write(fout,9203) descriptorindex	
		  if(descriptorindex.ge.1000  .and. descriptorindex.lt.10000)  write(fout,9204) descriptorindex		  
		  if(descriptorindex.ge.10000 .and. descriptorindex.lt.100000) write(fout,9205) descriptorindex
		  
9201	  format('struct.',I1'.txt')
9202	  format('struct.',I2'.txt')
9203	  format('struct.',I3'.txt')
9204	  format('struct.',I4'.txt')
9205	  format('struct.',I5'.txt')		  
		  
		  open(32,file=fout)
		  
          write(32,3200)
          write(32,3201) globalIndex, frame, i, descriptorindex
          write(32,3202)
          write(32,3203) (descriptor(j),j=1,descriptorsize)
          write(32,3204)

3200      format('#GLOBALINDEX  FRAME  COMPONENT  DESCRIPTORINDEX')
3201      format(4I12)
3202      format('#DESCRIPTOR')
3203      format(99I6)
3204      format('#ID EL NBONDS BONDED_IDS ')

          do j=1,natom
            if( cID(j).eq.i )then
              write(32,3205) j, el(j), bondsperatom(j), &
                             (bonds(j,k),k=1,bondsperatom(j))
3205          format(I8,A4,I8,99I8)
            endif
          enddo
		  
		  close(32)
		  
		  
          !!!!! Update Global Index !!!!!
          globalIndex = globalIndex + 1

        !!!!! End Loop Over Components !!!!!

        enddo

      !!!!! End Loop Over Frames !!!!!

      enddo

      close(21)
      close(30)
      close(31)

!!!!! Print Unique Desciptors !!!!!

      open(40,file='unique.descriptors.txt')
      write(40,4000)
4000  format('#DESCRIPTORINDEX  COUNT  DESCRIPTOR')

      do i=1,nunique
        write(40,4001) i, uniqueCount(i), (uniqueDescriptor(i,j),j=1,descriptorsize)
4001    format(99I12)
      enddo

      close(40)
	  
!!!!! Print Desciptor String !!!!!
	  
	  open(70,file='descriptor_string.txt')

	  write(70,7000)
7000  format('Natom_total')
	  	  
	  do i=1,ntype 
		atA = LEN_TRIM( typelist(i) )
		if(atA.eq.1) write(70,7011) typelist(i)
		if(atA.eq.2) write(70,7012) typelist(i)
7011    format('Natom_',A1)
7012    format('Natom_',A2)
	  enddo 

	  do i=1,ntype 
	    do j=i,ntype 
		  atA = LEN_TRIM( typelist(i) )
		  atB = LEN_TRIM( typelist(j) )
		  if(atA.eq.1 .and. atB.eq.1) write(70,7021) typelist(i), typelist(j) 
		  if(atA.eq.1 .and. atB.eq.2) write(70,7022) typelist(i), typelist(j)
		  if(atA.eq.2 .and. atB.eq.1) write(70,7023) typelist(i), typelist(j)		  
		  if(atA.eq.2 .and. atB.eq.2) write(70,7024) typelist(i), typelist(j)
7021      format('Nbond_',A1,'-',A1)		  
7022      format('Nbond_',A1,'-',A2)		  
7023      format('Nbond_',A2,'-',A1)
7024      format('Nbond_',A2,'-',A2)		  
		enddo 
	  enddo 


	  do i=1,ntype 
	    do j=1,ntype 
		  do k=i,ntype 
		    atA = LEN_TRIM( typelist(i) )
		    atB = LEN_TRIM( typelist(j) )
		    atC = LEN_TRIM( typelist(k) )
			if(atA.eq.1 .and. atB.eq.1 .and. atC.eq.1) write(70,7031) typelist(i), typelist(j), typelist(k)
			if(atA.eq.1 .and. atB.eq.1 .and. atC.eq.2) write(70,7032) typelist(i), typelist(j), typelist(k)
			if(atA.eq.1 .and. atB.eq.2 .and. atC.eq.1) write(70,7033) typelist(i), typelist(j), typelist(k)
			if(atA.eq.1 .and. atB.eq.2 .and. atC.eq.2) write(70,7034) typelist(i), typelist(j), typelist(k)			
			if(atA.eq.2 .and. atB.eq.1 .and. atC.eq.1) write(70,7035) typelist(i), typelist(j), typelist(k)
			if(atA.eq.2 .and. atB.eq.1 .and. atC.eq.2) write(70,7036) typelist(i), typelist(j), typelist(k)
			if(atA.eq.2 .and. atB.eq.2 .and. atC.eq.1) write(70,7037) typelist(i), typelist(j), typelist(k)
			if(atA.eq.2 .and. atB.eq.2 .and. atC.eq.2) write(70,7038) typelist(i), typelist(j), typelist(k)	
7031        format('Nangle_',A1,'-',A1,'-',A1)
7032        format('Nangle_',A1,'-',A1,'-',A2)
7033        format('Nangle_',A1,'-',A2,'-',A1)
7034        format('Nangle_',A1,'-',A2,'-',A2)
7035        format('Nangle_',A2,'-',A1,'-',A1)
7036        format('Nangle_',A2,'-',A1,'-',A2)
7037        format('Nangle_',A2,'-',A2,'-',A1)
7038        format('Nangle_',A2,'-',A2,'-',A2)
		  enddo 
		enddo 
	  enddo 
	  
	  close(70)

!!!!! End Program !!!!!

      end





