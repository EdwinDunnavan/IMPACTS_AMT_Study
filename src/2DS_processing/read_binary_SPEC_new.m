function read_binary_SPEC_new(infilename, outfilename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw base*.2DS file, and then write into NETCDF file 
%% Follow the SPEC manual 
%%  by Will Wu, 08/01/2014
%%  **************************
%   *** Modification Notes ***
%   **************************
%   * Modified to use memorymapfile to read in entire binary files
%     Modified to parallelize the decompression into maxNumCompThreads
%     number of subfiles.
%               Edwin Lee Dunnavan, 2023
%
%   * Modified to prevent termination during rare instance when attempting
%   to decode beyond the image buffer
%               Joe Finlon, 03/08/2017
%   * Added netCDF4 support and data compression
%               Joe Finlon, 02/13/2019
%   * Improvements in handling instances when prob TAS is incorrect
%               Joe Finlon & Wei Wu, 11/3/2019
%   * Support for applying time offset correction (e.g., SOCRATES)
%               Joe Finlon, 11/3/2019
%   * Changed how the optional flight time and TAS are read in
%               Joe Finlon, 02/07/2020
%   * Ensures the hour timestamp is less than 24 when saving to file
%               Joe Finlon, 02/10/2020
%	* Small fix to global attributes
%				Joe Finlon, 02/12/2020
%   Interface:
%       infilename: The input file name outfilename: The output file name
%       (e.g., '/path/imgData.date.2DS') varargin: Optional arguments,
%       separated by commas, containing an array of 1-HZ flight times and
%       true airspeed values
%               flt_time: Array of times in HHMMSS (00 UTC will have value
%                       of 0)
%               flt_tas: Array of true airspeeds [m/s]
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Added support for probe TAS ratio calculation ~ Joe Finlon 11/3/19,
% 02/07/20

%% NOTES: base* binary files are 2057 positions long with 4114 bytes of data.

tic

numThreads = maxNumCompThreads;

%numThreads = 12;

    disp(['Raw File: ', infilename])
   
    %% Create memory map of binary file:
    % Each line has 4114 bytes of data with 2057 elements (16 bits = 2
    % bytes).

    mem = memmapfile(infilename,'Format',...
                  {'uint16' [1,1] 'year';...
                   'uint16' [1,1] 'month';...
                   'uint16' [1,1] 'wkday';...
                   'uint16' [1,1] 'day';...
                   'uint16' [1,1] 'hour';...
                   'uint16' [1,1] 'minute';...
                   'uint16' [1,1] 'second';...
                   'uint16' [1,1] 'millisec';...
                   'uint16' [1,2048] 'data';...
                   'uint16' [1,1] 'discard'});

    kfile = length(mem.Data);

    splitlength = floor(kfile/numThreads);
    sublengths = ones(1,floor(kfile/splitlength))*splitlength;
    sublengths(end) = sublengths(end)+kfile-sum(sublengths);
    subfiles = mat2cell(1:kfile,1,sublengths);

    subfiles{numThreads} = subfiles{numThreads}(1:end-1); % Remove last one because of indexing

    % Added dynamic software version to netCDF metadata - Joe Finlon
    % 02/07/20
    versionID = fopen('version.txt', 'r');
    software_string = fscanf(versionID, '%s');
    fclose(versionID);

    %{ 

    Note: It seems like each line corresponds to a probe, either H or V,
    for instance, but original code rewinds back to previous line and seems
    to read in V as H.            
    %} 

     parfor kk = 1: numThreads

        %% Find subfiles
        kfile_temp = subfiles{kk};

        tasRatio = 1.0;

        kk1 = 1;
        kk2 = 1;

        outfilename1 = strcat(outfilename,num2str(kk),'.H.nc');
        outfilename2 = strcat(outfilename,num2str(kk),'.V.nc');
    
        fh = netcdf.create(outfilename1, 'NETCDF4'); % netCDF-4/HDF5 compression support - Added by Joe Finlon 02/13/19
        
        dimid0 = netcdf.defDim(fh,'time',netcdf.getConstant('NC_UNLIMITED'));
        dimid1 = netcdf.defDim(fh,'ImgRowlen',8);
        dimid2 = netcdf.defDim(fh,'ImgBlocklen',1700);
        
        NC_GLOBAL = netcdf.getConstant('NC_GLOBAL'); % Added file attributes ~ Joe Finlon 02/07/20
	    netcdf.putAtt(fh, NC_GLOBAL, 'Software', software_string);
	    netcdf.putAtt(fh, NC_GLOBAL, 'Creation Time', datestr(now, 'yyyy/mm/dd HH:MM:SS'));
	    netcdf.putAtt(fh, NC_GLOBAL, 'Probe Channel_Orientation', 'Horizontal');
        
        % Added data compression using 'defVarDeflate' argument ~ Joe Finlon 02/13/19
        varid0 = netcdf.defVar(fh,'year','short',dimid0); netcdf.defVarDeflate(fh, varid0, true, true, 9);
        varid1 = netcdf.defVar(fh,'month','byte',dimid0); netcdf.defVarDeflate(fh, varid1, true, true, 9);
        varid2 = netcdf.defVar(fh,'day','byte',dimid0); netcdf.defVarDeflate(fh, varid2, true, true, 9);
        varid3 = netcdf.defVar(fh,'hour','byte',dimid0); netcdf.defVarDeflate(fh, varid3, true, true, 9);
        varid4 = netcdf.defVar(fh,'minute','byte',dimid0); netcdf.defVarDeflate(fh, varid4, true, true, 9);
        varid5 = netcdf.defVar(fh,'second','byte',dimid0); netcdf.defVarDeflate(fh, varid5, true, true, 9);
        varid6 = netcdf.defVar(fh,'millisec','short',dimid0); netcdf.defVarDeflate(fh, varid6, true, true, 9);
        varid7 = netcdf.defVar(fh,'wkday','byte',dimid0); netcdf.defVarDeflate(fh, varid7, true, true, 9);
        varid8 = netcdf.defVar(fh,'data','uint',[dimid1 dimid2 dimid0]); netcdf.defVarDeflate(fh, varid8, true, true, 9);
        varid9 = netcdf.defVar(fh,'tas','double',dimid0); netcdf.defVarDeflate(fh, varid9, true, true, 9); netcdf.defVarFill(fh , varid9, false, -999.);
        varid10 = netcdf.defVar(fh,'tasRatio','double',dimid0); netcdf.defVarDeflate(fh, varid10, true, true, 9);

        netcdf.endDef(fh)
    
        fv = netcdf.create(outfilename2, 'NETCDF4');
        
        dimid01 = netcdf.defDim(fv,'time',netcdf.getConstant('NC_UNLIMITED'));
        dimid11 = netcdf.defDim(fv,'ImgRowlen',8);
        dimid21 = netcdf.defDim(fv,'ImgBlocklen',1700);
        
        NC_GLOBAL = netcdf.getConstant('NC_GLOBAL'); % Added file attributes ~ Joe Finlon 02/07/20
	    netcdf.putAtt(fv, NC_GLOBAL, 'Software', software_string);
	    netcdf.putAtt(fv, NC_GLOBAL, 'Creation Time', datestr(now, 'yyyy/mm/dd HH:MM:SS'));
	    netcdf.putAtt(fv, NC_GLOBAL, 'Probe Channel_Orientation', 'Vertical');
        
        % Added data compression using 'defVarDeflate' argument ~ Joe Finlon 02/13/19
        varid01 = netcdf.defVar(fv,'year','short',dimid01); netcdf.defVarDeflate(fv, varid01, true, true, 9);
        varid11 = netcdf.defVar(fv,'month','byte',dimid01); netcdf.defVarDeflate(fv, varid11, true, true, 9);
        varid21 = netcdf.defVar(fv,'day','byte',dimid01); netcdf.defVarDeflate(fv, varid21, true, true, 9);
        varid31 = netcdf.defVar(fv,'hour','byte',dimid01); netcdf.defVarDeflate(fv, varid31, true, true, 9);
        varid41 = netcdf.defVar(fv,'minute','byte',dimid01); netcdf.defVarDeflate(fv, varid41, true, true, 9);
        varid51 = netcdf.defVar(fv,'second','byte',dimid01); netcdf.defVarDeflate(fv, varid51, true, true, 9);
        varid61 = netcdf.defVar(fv,'millisec','short',dimid01); netcdf.defVarDeflate(fv, varid61, true, true, 9);
        varid71 = netcdf.defVar(fv,'wkday','byte',dimid01); netcdf.defVarDeflate(fv, varid71, true, true, 9);
        varid81 = netcdf.defVar(fv,'data','uint',[dimid11 dimid21 dimid01]); netcdf.defVarDeflate(fv, varid81, true, true, 9);
        varid91 = netcdf.defVar(fv,'tas','double',dimid0); netcdf.defVarDeflate(fv, varid91, true, true, 9); netcdf.defVarFill(fv , varid91, false, -999.);
        varid101 = netcdf.defVar(fv,'tasRatio','double',dimid0); netcdf.defVarDeflate(fv, varid101, true, true, 9);

        netcdf.endDef(fv)

        previousTAS = -999; % Joe Finlon 11/3/19

        %% Loop over all buffer strips in chunk
        for ind = kfile_temp

        %% Get lines
        [year,month, wkday,day, hour, minute, second, millisec, data]=get_mem_data(mem,ind);
        [~,~, ~,~, ~, ~,~, ~, data1]=get_mem_data(mem,ind+1);

        datan=[data data1];
        datan=datan';
        
        try 
        [imgH, imgV,  imgTAS, previousTAS]=get_img(datan, previousTAS);

        catch

          continue

        end


        sizeimg= size(imgH);
        if sizeimg(2)>1700
            imgH=imgH(:,1:1700);
        end
        
        sizeimg= size(imgV);
        if sizeimg(2)>1700
            imgV=imgV(:,1:1700);
        end
        
        if sum(sum(imgH))~=0
            img1 = zeros(8,1700);
            for  mmm=1:8
                img1(mmm,1:1700)=sixteen2int(imgH((mmm-1)*16+1:mmm*16,1:1700));
            end
            % Ensures the hour timestamp is less than 24 when saving to file ~ Added by Joe Finlon 02/10/20
            if hour>=24
                hour = hour - 24;
            end

            netcdf.putVar ( fh, varid0, kk1-1, 1, year );
            netcdf.putVar ( fh, varid1, kk1-1, 1, month );
            netcdf.putVar ( fh, varid2, kk1-1, 1, day );
            netcdf.putVar ( fh, varid3, kk1-1, 1, hour );
            netcdf.putVar ( fh, varid4, kk1-1 , 1, minute );
            netcdf.putVar ( fh, varid5, kk1-1, 1, second );
            netcdf.putVar ( fh, varid6, kk1-1, 1, millisec );
            netcdf.putVar ( fh, varid7, kk1-1 , 1, wkday );
            netcdf.putVar ( fh, varid8, [0, 0, kk1-1], [8,1700,1], img1 );
            netcdf.putVar ( fh, varid9, kk1-1, 1, imgTAS); % Added variable ~ Joe Finlon 11/3/19
            netcdf.putVar ( fh, varid10, kk1-1, 1, tasRatio); % Added variable ~ Joe Finlon 11/3/19

            if mod(kk1,100) == 0

                  fprintf('%s\n',datestr(datetime(year,month,day,hour,minute,second,millisec)))
            end

            kk1 = kk1+1;

            
        end
        
        if sum(sum(imgV))~=0
            img2 = zeros(8,1700);
            for  mmm=1:8
                img2(mmm,1:1700)=sixteen2int(imgV((mmm-1)*16+1:mmm*16,1:1700));
            end
            % Ensures the hour timestamp is less than 24 when saving to file ~ Added by Joe Finlon 02/10/20
            if hour>=24
                hour = hour - 24;
            end

            netcdf.putVar ( fv, varid01, kk2-1, 1, year );
            netcdf.putVar ( fv, varid11, kk2-1, 1, month );
            netcdf.putVar ( fv, varid21, kk2-1, 1, day );
            netcdf.putVar ( fv, varid31, kk2-1, 1, hour );
            netcdf.putVar ( fv, varid41, kk2-1, 1, minute );
            netcdf.putVar ( fv, varid51, kk2-1, 1, second );
            netcdf.putVar ( fv, varid61, kk2-1, 1, millisec );
            netcdf.putVar ( fv, varid71, kk2-1, 1, wkday );
            netcdf.putVar ( fv, varid81, [0, 0, kk2-1], [8,1700,1], img2 );
            netcdf.putVar ( fv, varid91, kk2-1, 1, imgTAS); % Added variable ~ Joe Finlon 11/3/19
            netcdf.putVar ( fv, varid101, kk2-1, 1, tasRatio); % Added variable ~ Joe Finlon 11/3/19


            if mod(kk2,100) == 0
                  fprintf('%s\n',datestr(datetime(year,month,day,hour,minute,second,millisec)))
            end

            kk2 = kk2+1;

        end


        end


        netcdf.close(fh);  
        netcdf.close(fv);   


    end
    
   

    toc


end



function [imgH, imgV, tas, tasPrev]=get_img(buf,tasPrev)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Decompress the image 
%%  Follow the SPEC manual 
%%  by Will Wu, 06/20/2013
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imgH=zeros(128,1700);
    imgV=zeros(128,1700);
    tas = tasPrev; % TAS will be last known value if not overwritten in this subroutine ~ Added by Joe Finlon 11/3/19
    iSlice=0;
    iii=1;
    while iii+4<=2048 % iii+4 Apparently a Joe Finlon fix.
        if 12883==buf(iii) %'0011001001010011'
              nH=bitand(buf(iii+1), 4095); %bin2dec('0000111111111111'));
              bHTiming=bitand(buf(iii+1), 4096); %bin2dec('0001000000000000'))/2^13;
              nV=bitand(buf(iii+2), 4095); %bin2dec('0000111111111111'));
              bVTiming=bitand(buf(iii+2), 4096); %bin2dec('0001000000000000'))/2^13;
              PC = buf(iii+3);
              nS = buf(iii+4);
              NHWord=buf(iii+1);
              NVWord=buf(iii+2);      
              
              iii=iii+5;
              if bHTiming~=0 || bVTiming~=0     
                  iii=iii+nH+nV;

              elseif nH~=0 && iii+nH-1<=length(buf) % Watch for index outside of image buffer - Added by Joe Finlon - 03/08/17
                  jjj=1;
                  kkk=0;

                  while iii+kkk<=length(buf) && jjj<=nS && kkk<nH-2 % Added by Joe Finlon - Last 2 slices is the time - 03/08/17
                      aa=bitand(buf(iii+kkk),16256)/2^7;  %bin2dec('0011111110000000')
                      bb=bitand(buf(iii+kkk),127); %bin2dec('0000000001111111')
                      imgH(min(128,bb+1):min(aa+bb,128),iSlice+jjj)=1;
                      bBase=min(aa+bb,128);
                      kkk=kkk+1;

                      while( iii+kkk<=length(buf) && bitand(buf(iii+kkk),16384)==0  && kkk<nH-2) % Added by Joe Finlon - 03/08/17
                          aa=bitand(buf(iii+kkk),16256)/2^7;
                          bb=bitand(buf(iii+kkk),127);
                          imgH(min(128,bBase+bb+1):min(bBase+aa+bb,128),iSlice+jjj)=1;
                          bBase=min(bBase+aa+bb,128);
                          kkk=kkk+1;
                      end
                      jjj=jjj+1;
                  end
                  iSlice=iSlice+nS+2;

                  imgH(:,iSlice-1)='10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010';
                  imgH(:,iSlice-1)=imgH(:,iSlice-1)-48;
                  imgH(:,iSlice)=1;
                  tParticle=buf(iii+nH-2)*2^16+buf(iii+nH-1);
                  imgH(:,iSlice)=dec2bin(tParticle,128)-48;
                  imgH(97:128,iSlice)=dec2bin(tParticle,32)-48;
                  imgH(49:64,iSlice)=dec2bin(NHWord,16)-48;
                  imgH(65:80,iSlice)=dec2bin(PC,16)-48;
                  imgH(81:96,iSlice)=dec2bin(nS,16)-48;
                  iii=iii+nH;

              elseif nV~=0 && iii+nV-1<=length(buf) % Watch for index outside of image buffer - Added by Joe Finlon - 03/08/17
                  jjj=1;
                  kkk=0;

                  while iii+kkk<=length(buf) && jjj<=nS && kkk<nV-2 % Added by Joe Finlon - Last 2 slices is the time - 03/08/17
                      aa=bitand(buf(iii+kkk),16256)/2^7;  %bin2dec('0011111110000000')
                      bb=bitand(buf(iii+kkk),127); %bin2dec('0000000001111111')
                      imgV(min(128,bb+1):min(aa+bb,128),iSlice+jjj)=1;
                      bBase=min(aa+bb,128);
                      kkk=kkk+1;

                      while( iii+kkk<=length(buf) && bitand(buf(iii+kkk),16384)==0  && kkk<nV-2) % Added by Joe Finlon - 03/08/17
                          aa=bitand(buf(iii+kkk),16256)/2^7;
                          bb=bitand(buf(iii+kkk),127);
                          imgV(min(128,bBase+bb+1):min(bBase+aa+bb,128),iSlice+jjj)=1;
                          bBase=min(bBase+aa+bb,128);
                          kkk=kkk+1;
                      end
                      jjj=jjj+1;
                  end
                  iSlice=iSlice+nS+2;

                  imgV(:,iSlice-1)='10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010';
                  imgV(:,iSlice-1)=imgV(:,iSlice-1)-48;
                  imgV(:,iSlice)=1;
                  tParticle=buf(iii+nV-2)*2^16+buf(iii+nV-1);
                  imgV(:,iSlice)=dec2bin(tParticle,128)-48;
                  imgV(97:128,iSlice)=dec2bin(tParticle,32)-48;
                  imgV(49:64,iSlice)=dec2bin(NVWord,16)-48;
                  imgV(65:80,iSlice)=dec2bin(PC,16)-48;
                  imgV(81:96,iSlice)=dec2bin(nS,16)-48;
                  iii=iii+nV;
              end
              
        elseif 18507==buf(iii)

            tasTemp = typecast(uint32(bin2dec([dec2bin(buf(iii-1+50),16) dec2bin(buf(iii-1+51),16)])) ,'single');
            nHOL = buf(iii-1+44);
            nVOL = buf(iii-1+45);
            % Update TAS value for current record ~ Joe Finlon 11/3/19
            if tasTemp~=tasPrev
                if (tasTemp==170) || (nHOL+nVOL>0)
                    tas = tasPrev;
                else
                    tas = tasTemp;
                end
                tasPrev = tas; % update TAS for use in next iteration
            end
            iii = iii + 53;
        
        elseif 19787==buf(iii)
            
            iii = iii + 23;
            
        else
            iii=iii+1;

        end
    end

end



function [year,month, wkday,day, hour, minute, second, millisec, data]=get_mem_data(mem,ind)

        year=double(mem.Data(ind).year);
        month=double(mem.Data(ind).month);
        wkday=double(mem.Data(ind).wkday);
        day=double(mem.Data(ind).day);
        hour=double(mem.Data(ind).hour);
        minute = double(mem.Data(ind).minute);
        second=double(mem.Data(ind).second);
        millisec=double(mem.Data(ind).millisec);
        data = double(mem.Data(ind).data);
end


function intres=sixteen2int(original)

intres=zeros(1,1700);
for i=1:16
    temp=original(i,:)*2^(16-i);
    intres=intres+temp;
end
end

