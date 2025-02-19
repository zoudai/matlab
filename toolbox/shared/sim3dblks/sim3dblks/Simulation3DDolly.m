classdef Simulation3DDolly<Simulation3DActor&...
Simulation3DHandleMap





    properties
        Translation(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=zeros(5,3);
        Rotation(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=zeros(5,3);
        Scale(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}=ones(5,3);
    end

    properties(Nontunable)

        Mesh='One-axle dolly';

        ActorTag='SimulinkVehicle1';
    end

    properties(Hidden,Constant)
        MeshSet=matlab.system.internal.MessageCatalogSet({'shared_sim3dblks:sim3dblkDolly:oneaxledolly',...
        'shared_sim3dblks:sim3dblkDolly:twoaxledolly',...
        'shared_sim3dblks:sim3dblkDolly:threeaxledolly'});
    end

    properties(Access=private)
VehObj
VehicleType
ActorColor
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            self.VehicleType=sim3d.utils.internal.StringMap.fwd(self.Mesh);
            self.VehObj=sim3d.auto.Dolly(self.ActorTag,self.VehicleType,...
            'Color','white',...
            'Translation',self.Translation,...
            'Rotation',self.Rotation,...
            'Scale',self.Scale);
            self.VehObj.setup();
            self.VehObj.reset();
            self.ModelName=['Simulation3DDolly/',self.ActorTag];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],self.VehObj);
            end
        end

        function stepImpl(self,translation,rotation)

            translation(:,3)=-translation(:,3);
            rotation=[fliplr(rotation(:,1:2)),rotation(:,3)];

            if coder.target('MATLAB')
                if~isempty(self.VehObj)
                    self.VehObj.writeTransform(single(translation),single(rotation),single(self.Scale));
                end
            end
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'terminating')
                if coder.target('MATLAB')
                    if~isempty(self.VehObj)
                        self.VehObj.delete();
                        self.VehObj=[];
                        if self.loadflag
                            self.Sim3dSetGetHandle([self.ModelName,'/VehObj'],[]);
                        end
                    end
                end
            end
        end

        function resetImpl(~)

        end

        function loadObjectImpl(self,s,wasInUse)
            self.VehicleType=s.VehicleType;
            self.ActorColor=s.ActorColor;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Mesh=s.Mesh;
            self.ActorTag=s.ActorTag;
            self.ModelName=s.ModelName;
            if self.loadflag
                self.VehObj=self.Sim3dSetGetHandle([self.ModelName,'/VehObj']);
            else
                self.VehObj=s.VehObj;
            end

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DActor(self);

            s.VehObj=self.VehObj;
            s.VehicleType=self.VehicleType;
            s.ActorColor=self.ActorColor;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Mesh=self.Mesh;
            s.ActorTag=self.ActorTag;
            s.ModelName=self.ModelName;
        end
        function icon=getIconImpl(~)
            icon={'Dolly'};
        end

        function[nrows,ncols]=getInputPortSize(self)

            ncols=3;
            dollyType=sim3d.utils.internal.StringMap.fwd(self.Mesh);
            switch dollyType
            case 'OneAxleDolly'
                nrows=5;
            case 'TwoAxleDolly'
                nrows=8;
            case 'ThreeAxleDolly'
                nrows=11;
            end
        end

        function validatePropertiesImpl(self)

            [nrows,ncols]=getInputPortSize(self);

            initialTranslationSize=size(self.Translation,1);
            initialRotationSize=size(self.Rotation,1);
            isok=(initialTranslationSize==initialRotationSize);
            if isok
                isok=(initialTranslationSize==nrows);
            end
            if~isok
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidInitialTransform',nrows,ncols));
            end
        end

        function validateInputsImpl(self,translation,rotation)
            [nrows,ncols]=getInputPortSize(self);
            translationSize=size(translation);
            rotationSize=size(rotation);

            if(~isequal(translationSize,[nrows,ncols]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidTranslationSize',nrows,ncols));
            end
            if(~isequal(rotationSize,[nrows,ncols]))
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidRotationSize',nrows,ncols));
            end
        end
    end

    methods(Access=public)
        function[Transformation,Rotation,Scale]=getPosition(self)
            [Transformation,Rotation,Scale]=self.VehObj.read();
        end
    end
end

