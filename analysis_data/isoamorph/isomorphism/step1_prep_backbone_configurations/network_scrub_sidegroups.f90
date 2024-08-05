      program network_scrub_sidegroups
      implicit none

      double precision, allocatable :: r(:,:)
      double precision, allocatable :: rcut(:,:), rcut2(:,:)
      double precision :: cell(3)
      double precision :: dumFloat
      double precision :: rij2, rr

      integer, allocatable :: bonds(:,:)
      integer, allocatable :: bondsperatom(:)
      integer, allocatable :: attype(:)
      integer, allocatable :: atompertype(:)
      integer :: natom, natomkeep, ntype
      integer :: frame, nframe 
      integer :: index, ii, jj, dumInt 
      integer :: i, j, k

      character*2, allocatable :: typelist(:)
      character*2 :: el 
      character*100 :: finGEN, finXYZ, finLMP, foutLMP

!!!!! Set Parameters !!!!!

      !Input File Names (check commented sections to switch between XYZ/LAMMPSTRJ
	  finGEN   = 'system.gen'       !Reference gen file contains atom type maping and cell 
	  !finXYZ   = 'geo_end.xyz'     !If reading in XYZ, uncomment open/read file 20 lines   
      finLMP   = 'dump.lammpstrj'   !If reading in LAMMPSTRJ, uncomment open/read file 21 lines 

      !Output File Name      
	  foutLMP  = 'dump.backbones.lammpstrj'

      nframe = 100 	  

!!!!! Read in Parameters !!!!!

      open(20,file='bond_defs.txt')
      read(20,*)
      read(20,*) ntype

      allocate (typelist(ntype))
      allocate (rcut(ntype,ntype),rcut2(ntype,ntype))

      !Get atom types
      read(20,*)
      do i=1,ntype
        read(20,*) index, typelist(index)
      enddo
      read(20,*)

      !Get bond cutoff definitions
      do i=1,ntype
        do j=i,ntype
          read(20,*) ii, jj, rcut(ii,jj)
          rcut(jj,ii) = rcut(ii,jj)
          rcut2(ii,jj) = rcut(ii,jj)*rcut(ii,jj)
          rcut2(jj,ii) = rcut2(ii,jj)
        enddo
      enddo

      close(20)
	  
!!!!! Get cell and atom types as integers !!!!! 

	  open(20,file=finGEN)
	  read(20,*) natom	  
	  read(20,*)
      allocate (r(natom,3))
      allocate (attype(natom)) 
      allocate (bonds(natom,natom))
      allocate (bondsperatom(natom))	  
	  do i=1,natom 
		read(20,*) index, attype(index)
	  enddo 
	  read(20,*) 
	  read(20,*) cell(1) 
	  read(20,*) dumFloat, cell(2)
	  read(20,*) dumFloat, dumFloat, cell(3)
	  close(20)

!!!!! Get Connections !!!!!

	  !open(20,file=finXYZ)
	  open(21,file=finLMP)      
	  open(31,file=foutLMP)

      do frame=1,nframe

        !!!!! Get Coordinates !!!!!
		!read(20,*)
		!read(20,*)
        !do i=1,natom
        !  read(20,*) el, (r(i,j),j=1,3)
        !enddo
		do i=1,9
          read(21,*)
        enddo 
        do i=1,natom 
          read(21,*) index, dumInt, (r(index,j),j=1,3)
        enddo 
        
        !!!!! Get Bonding Info !!!!!
        bondsperatom = 0
        do i=1,natom-1
         do j=i+1,natom
          rij2 = 0.0d0
          do k=1,3
            rr = r(i,k) - r(j,k)
            rr = rr - cell(k)*dfloat(nint(rr/cell(k)))
            rij2 = rij2 + rr*rr
          enddo
          if( rij2 .le. rcut2(attype(i),attype(j)) )then
            bondsperatom(i) = bondsperatom(i) + 1
            bondsperatom(j) = bondsperatom(j) + 1
            bonds(i,bondsperatom(i)) = j
            bonds(j,bondsperatom(j)) = i
          endif
         enddo
        enddo

		!!!!! Find Atoms in Backbones !!!!! 
		natomkeep = 0
		do i=1,natom 
		  if(bondsperatom(i).ge.2) natomkeep = natomkeep + 1 
		enddo 

		!!!!! Print to LMP file !!!!!	
		write(31,3101)
		write(31,3102) frame 
		write(31,3103)
		write(31,3104) natomkeep 
		write(31,3105)
		write(31,3106) 0.0d0, cell(1)
		write(31,3107) 0.0d0, cell(2)
		write(31,3108) 0.0d0, cell(3)
		write(31,3109)

3101    format('ITEM: TIMESTEP')
3102    format(I12)
3103    format('ITEM: NUMBER OF ATOMS')
3104    format(I12)
3105    format('ITEM: BOX BOUNDS pp pp pp')
3106    format(2F24.6)
3107    format(2F24.6)
3108    format(2F24.6)
3109    format('ITEM: ATOMS id type xu yu zu ')
3110    format(I8,I4,3ES16.8)

        do i=1,natom
		  if(bondsperatom(i).ge.2)then 
            write(31,3110) i, attype(i), (r(i,j),j=1,3)
		  endif 
        enddo

      enddo

      !close(20)
      close(21)      
      close(31)
	  
!!!!! End Program !!!!!

      end





