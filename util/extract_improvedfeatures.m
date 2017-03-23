function extract_improvedfeatures(videofile, outfile)   
    % TODO: Change the paths and improved trajectory binary paths if necessary   
	if ispc
		videofile = strrep(videofile, '&', '^&'); outfile = strrep(outfile, '&', '^&');
		videofile = strrep(videofile, '(', '^('); outfile = strrep(outfile, '(', '^(');
        videofile = strrep(videofile, ')', '^)'); outfile = strrep(outfile, ')', '^)');
	else
		videofile = strrep(videofile, '&', '\&'); outfile = strrep(outfile, '&', '\&');
		videofile = strrep(videofile, '(', '\('); outfile = strrep(outfile, '(', '\(');
        videofile = strrep(videofile, ')', '\)'); outfile = strrep(outfile, ')', '\)');
	end
    system(sprintf('%s %s -o %s',fullfile('bin','DenseTrackStab'),videofile,outfile));
end