      program convert_xyz2lammps
      implicit none

!!!!! This program reads through the trajectory dumped to geo_end.xyz
!!!!! and converts it to a LAMMPS-style dump that includes the PBC cell. 
!!!!! The progam assumes that the simulation cell does not change during 
!!!!! the simulation and matches the initial specification in system.gen. 
!!!!! It also assumes that the cell is orthorhombic.  

      double precision, allocatable :: r(:,:)
      double precision :: lx, ly, lz
      double precision :: dumFloat

      integer :: natom, step, ncarbon
      integer :: i, j, io, index, attype

      character*2, allocatable :: el(:)
      character*20 :: dumChar

!!!!! Get Parameters !!!!!

      open(20,file='system.gen')
      read(20,*) natom
      read(20,*)

      do i=1,natom
        read(20,*)
      enddo

	  !Get simulation box assuming orthorhombic 
      read(20,*)
      read(20,*) lx
      read(20,*) dumFloat, ly
      read(20,*) dumFloat, dumFloat, lz

      close(20)

      allocate (r(natom,3))
      allocate (el(natom))

!!!!! Convert XYZ to LAMMPSTRJ !!!!!

      open(20,file='geo_end.xyz')
      open(21,file='system.lammpstrj')
      open(22,file='onlycarbon.lammpstrj')

      do

        read(20,*,IOSTAT=io)

        if(io.ne.0)then
          exit
        else

          read(20,*) dumChar, dumChar, step
          do i=1,natom
            read(20,*) el(i), (r(i,j),j=1,3)
          enddo

          write(21,2101)
          write(21,2102) step
          write(21,2103)
          write(21,2104) natom
          write(21,2105)
          write(21,2106) 0.0d0, lx, 0.0d0
          write(21,2107) 0.0d0, ly, 0.0d0
          write(21,2108) 0.0d0, lz, 0.0d0
          write(21,2109)

2101      format('ITEM: TIMESTEP')
2102      format(I12)
2103      format('ITEM: NUMBER OF ATOMS')
2104      format(I12)
2105      format('ITEM: BOX BOUNDS xy xz yz pp pp pp')
2106      format(3F24.6)
2107      format(3F24.6)
2108      format(3F24.6)
2109      format('ITEM: ATOMS id type xu yu zu')
2110      format(I12, I4, 3ES16.8)

          ncarbon = 0

          do i=1,natom
            if(el(i).eq.'C')then
              attype = 1
              ncarbon = ncarbon + 1
            endif
            if(el(i).eq.'H' .or. el(i).eq.'F') attype = 2
            write(21,2110) i, attype, (r(i,j),j=1,3)
          enddo

          !!!!! Dump only Carbons !!!!!

          write(22,2101)
          write(22,2102) step
          write(22,2103)
          write(22,2104) ncarbon
          write(22,2105)
          write(22,2106) 0.0d0, lx, 0.0d0
          write(22,2107) 0.0d0, ly, 0.0d0
          write(22,2108) 0.0d0, lz, 0.0d0
          write(22,2109)

2201      format('ITEM: TIMESTEP')
2202      format(I12)
2203      format('ITEM: NUMBER OF ATOMS')
2204      format(I12)
2205      format('ITEM: BOX BOUNDS xy xz yz pp pp pp')
2206      format(3F24.6)
2207      format(3F24.6)
2208      format(3F24.6)
2209      format('ITEM: ATOMS id type xu yu zu')
2210      format(I12, I4, 3ES16.8)

          index = 0

          do i=1,natom
            if(el(i).eq.'C')then
              attype = 1
              index = index + 1
              write(22,2210) index, attype, (r(i,j),j=1,3)
            endif
          enddo


        endif

      enddo

      close(20)
      close(21)
      close(22)

!!!!! End !!!!!

      end
