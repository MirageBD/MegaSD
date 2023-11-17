; LBA = Logical block addressing

; fat_begin_lba				= Partition_LBA_Begin + Number_of_Reserved_Sectors;
; cluster_begin_lba			= Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT);
; sectors_per_cluster		= BPB_SecPerClus;
; root_dir_first_cluster	= BPB_RootClus;

; MASTER BOOT RECORD

.define mbr_partitionentry1_offset										$01be
.define mbr_partitionentry2_offset										$01ce
.define mbr_partitionentry3_offset										$01de
.define mbr_partitionentry4_offset										$01ee
.define mbr_signature_offset											$01fe

; PARTITION ENTRIES

.define pe_state_offset													$00
.define pe_partstarthead_offset											$01
.define pe_partstartsector_offset										$02
.define pe_parttype_offset												$04
.define pe_partendhead_offset											$05
.define pe_partendsector_offset											$06
.define pe_numberofsectorsbetweenmbrandfirstsectorinpartition_offset	$08
.define pe_numberofsectorsinpartition_offset							$0c

; BOOT RECORD INFORMATION (1st sector in partition = $0800)

.define bri_jumpcode_offset												$0000
.define bri_oemname_offset												$0003
.define bri_bytespersector_offset										$000b
.define bri_sectorspercluster_offset									$000d   ; !!!!
.define bri_reservedsectors_offset										$000e   ; !!!! (fs_fat32_system_sectors in hyppo)
.define bri_numberoffatcopies_offset									$0010   ; !!!! (should be 2)
.define bri_maxrootdirentries_offset									$0011	; n/a for fat32
.define bri_numsectorsinpartitionsmallerthan32mb_offset					$0013	; n/a for fat32
.define bri_mediadescriptor_offset										$0015	; $f8 for hard disks
.define bri_sectorsperfatinolderfatsystems_offset						$0016	; n/a for fat32
.define bri_sectorspertrack_offset										$0018
.define bri_numberofheads_offset										$001a
.define bri_numberofhiddensectorsinpartition_offset						$001c
.define bri_numberofsectorsinpartition_offset							$0020
.define bri_numberofsectorsperfat_offset								$0024
.define bri_flags_offset												$0028	; bits 0-4 = indicateactive fat copy, bit 7 = fat mirroring enabled
.define bri_versionoffat32drive_offset									$002a	; highbyte = major, lowbyte = minor
.define bri_clusternumberofstartofrootdirectory_offset					$002c   ; !!!!
.define bri_sectornumberoffilesysteminformationsector_offset			$0030	; see structure below. referenced from the start of partition
.define bri_sectornumberofbackupbootsector_offset						$0032	; referenced from the start of partition
.define bri_reserved_offset												$0034
.define bri_logicaldrivenumberofpartition_offset						$0040
.define bri_unused_offset												$0041	; could be highbyte of previous entry
.define bri_extendedsignature_offset									$0042	; $29
.define bri_serialnumberofpartition_offset								$0043
.define bri_volumenameofpartition_offset								$0047
.define bri_fatname_offset												$0052	; FAT32
.define bri_executablecode_offset										$005a
.define bri_signature_offset											$01fe	; $55AA

		; 0x?0000000									; free cluster
		; 0x?0000001									; reserved for internal purposes
		; 0x?0000002 - 0x?FFFFFEF						; used as data clusters
		; 0x?FFFFFF0 - 0x?FFFFFF5						; reserved in some contexts
		; 0x?FFFFFF6									; reserved, do not use
		; 0x?FFFFFF7									; bad sector in cluster or reserved cluster
		; 0x?FFFFFF8 - 0x?FFFFFFF						; last cluster in file (EOC)
