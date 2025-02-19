classdef RptgenSL_CForm<slreportgen.rpt2api.RptgenSL_CReport


































































    methods

        function obj=RptgenSL_CForm(component,rptFileConverter)
            obj@slreportgen.rpt2api.RptgenSL_CReport(component,rptFileConverter);
        end

    end

    methods(Access=protected)

        function writeConvertedChildren(this)


            import mlreportgen.rpt2api.*

            children=getComponentChildren(this);
            nChild=numel(children);
            if nChild>0

                fwrite(this.FID,"% Fill holes in the form"+newline);





                fprintf(this.FID,'while ~strcmp(rptObj.Document.CurrentHoleId,"#end#")\n');
                fprintf(this.FID,"switch rptObj.Document.CurrentHoleId\n");



                writeConvertedChildren@mlreportgen.rpt2api.RptgenML_CReport(this);




                fprintf(this.FID,"end\n");
                fprintf(this.FID,"moveToNextHole(rptObj.Document);\n");
                fprintf(this.FID,"end\n\n");
            end
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import slreportgen.rpt2api.RptgenSL_CForm
            templateFolder=fullfile(RptgenSL_CForm.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
