
function [h,tl,AngleArcLabelvec,ar1,ar2] = plotAngleArc3d(varargin)
%        [h,AngleArcLabelvec] = plotAngleArc3d(WhichAngle,vec1,vec2,originvec,ArcRadius,ArcStyle,ArcLabel,ArcLabelFontSize,ArrowedAngle)
%PLOTANGLEARC3D
%   This function plots the 3d convex or concave angle arc between the two
%   vectors vec1 and vec2 whose tails are adjacent and centered in
%   originvec. In the case of orthogonal vectors the circumference arc is
%   replaced by a square, which is the canonical (universal) representation
%   of the right angle.
%
%   The function provides the graphic object (plot) handle and an
%   auxiliary vector indicating the center of the angle arc (with
%   slightly upscaled magnitude) for labeling purposes.
%
%   It is quite reasonable for originvec to be the point of
%   application of both vectors vec1 and vec2.
%
%   %%% Input
%                     %%%%%
%                    %% +1 := convex
%    -WhichAngle := %%%                          (necessary)
%                    %% -1 := concave
%                     %%%%%
%
%    -vec1 := 3 x 1 vector                       (necessary)
%
%    -vec2 := 3 x 1 vector                       (necessary)
%
%    -originvec := 3 x 1 vector                  ([0;0;0] default)
%
%    -ArcRadius := radius of the angle           (0.3 default)
%
%    -ArcStyle := cell array containing
%                 arc angle plot style.          ({'-k'} default)
%                 The cell array will be
%                 expanded in input to the
%                 plot3 function
%
%    -ArcLabel := character array storing        ('' default)
%                 the label assigned to the
%                 angle. If left empty no
%                 label is assigned
%
%    -ArcLabelStyle := cell array containing     ({'FontSize',10} default)
%                      arc label text style.
%                      The cell array will be
%                      expanded in input to
%                      the text function
%
%                       %%%%%
%                      %%% 1 := AngleArrow on (default arrow size)
%                      %%
%    -ArrowedAngle := %%% 0 := AngleArrow off    (0 default)
%                      %%
%                      %%% Any value > 0 (customize arrow size)
%                       %%%%%
%     [notice that arrow size increases with the length of the angle arc]
%
%   %%% Output
%    -h := angle arc graphic object handle
%
%    -AngleArcLabelvec := 3 x 1 vector locating the center of the angle arc
%                         (with slightly upscaled magnitude) for labeling
%                         purposes
%
%   %%% Example (randomized)
%    WhichAngle = sign(randn);
%    vec1 = randn(3,1);
%    vec1 = vec1/norm(vec1);
%    vec2 = randn(3,1);
%    vec2 = vec2/norm(vec2);
%    originvec = randn(3,1);
%    ArcRadius = 0.5;
%    ArcStyle = {'-r','LineWidth',1.7};
%    ArcLabel = 'try $\theta_0$';
%    ArcLabelStyle = {'Interpreter','latex','FontSize',13};
%    ArrowedAngle = 1;
%    figure
%    hold on
%    [h,AngleArcLabelvec] = plotAngleArc3d(WhichAngle,vec1,vec2,originvec,ArcRadius,ArcStyle,ArcLabel,ArcLabelStyle,ArrowedAngle)
%    quiver3(originvec(1),originvec(2),originvec(3),vec1(1),vec1(2),vec1(3))
%    quiver3(originvec(1),originvec(2),originvec(3),vec2(1),vec2(2),vec2(3))
%    axis equal
%
%Alessandro Beolchi, 12 April 2023
% Copyright (c) 2023, Alessandro Beolchi
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
%
% * Neither the name of  nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

tl = 0;

if nargin < 3
    error('At least three inputs are required in the following order: (1) WhichAngle := +1 (convex) or -1 (concave) | (2) vec1 := 3 x 1 vector | (3) vec2 := 3 x 1 vector')
elseif nargin > 9
    error('At most nine inputs can be provided to this function')
elseif nargin >= 3
    % Extract necessary input parameters
    WhichAngle = varargin{1};
    vec1 = varargin{2};
    vec2 = varargin{3};
    if WhichAngle ~= +1 && WhichAngle ~= -1
        error('First input "WhichAngle" must be either +1 for convex angle or -1 for concave angle')
    end
    sortedsize1 = sort(size(vec1)); % output should be [1 3] for both row and column input vec1
    sortedsize2 = sort(size(vec2)); % output should be [1 3] for both row and column input vec2
    if (sortedsize1(1) ~= 1 && sortedsize1(2) ~= 3) || (sortedsize2(1) ~= 1 && sortedsize2(2) ~= 3)
        error('One (or both) of the input vectors "vec1" and "vec2" is (or are) not three-dimensional vector (or vectors)')
    end
    vec1 = reshape(vec1,3,1); % reshape vec1 (in the case it has been provided as a row vector)
    vec2 = reshape(vec2,3,1); % reshape vec2 (in the case it has been provided as a row vector)
    % Normalize input vectors
    uvec1 = vec1/norm(vec1);
    uvec2 = vec2/norm(vec2);
    % Define vector normal to the plane containing vec1 and vec2
    normvec = cross(uvec1,uvec2);
    if norm(normvec) == 0
        stheta = 0;
        normuvec = [0;0;1];
        if uvec1 == uvec2
            ctheta = 1;
            theta = 0;
        elseif uvec1 == -uvec2
            ctheta = -1;
            theta = pi;
        end
    else
    % Compute sine of the angle between vec1 and vec2
    stheta = norm(normvec);
    % Define unit vector normal to the plane containing vec1 and vec2
    normuvec = normvec/stheta;
    % Compute cosine of the angle between vec1 and vec2
    ctheta = dot(uvec1,uvec2);
    % Compute the angle between vec1 and vec2
    theta = 2*atan(stheta/(1 + ctheta));
    end
    % Define the rotation matrix from Plot reference frame to Angle reference frame
    auvec3 = normuvec;
    auvec1 = uvec1;
    auvec2 = cross(auvec3,auvec1);
    RPA = [auvec1';auvec2';auvec3'];
    % Define the span of the circumference arc
    ArcDensity = 101; % avoid useless high values
    if WhichAngle == +1 % convex
        ArcSpan = linspace(0,theta,ArcDensity); % 1 x ArcDensity vector
        AngleLength = theta;
    else % WhichAngle == -1 % concave
        ArcSpan = linspace(theta,2*pi,ArcDensity); % 1 x ArcDensity vector
        AngleLength = 2*pi - theta;
    end
    switch nargin
        case 3
            % Set remaining optional parameters to default
            originvec = [0;0;0];
            ArcRadius = 0.3;
            ArcStyle = {'-k'};
            ArcLabel = '';
            ArcLabelStyle = {'FontSize',10};
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            if ~isempty(ArcLabel)
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
            end
        case 4
            % Extract optional input parameters
            originvec = varargin{4};
            % Set remaining optional parameters to default
            ArcRadius = 0.3;
            ArcStyle = {'-k'};
            ArcLabel = '';
            ArcLabelStyle = {'FontSize',10};
            % Check optional input parameters
            sortedsize3 = sort(size(originvec)); % output should be [1 3] for both row and column input originvec
            if sortedsize3(1) ~= 1 && sortedsize3(2) ~= 3
                error('Fourth input vector "originvec" is not a three-dimensional vector')
            end
            originvec = reshape(originvec,3,1); % reshape originvec (in the case it has been provided as a row vector)
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
        case 5
            % Extract optional input parameters
            originvec = varargin{4};
            ArcRadius = varargin{5};
            % Set remaining optional parameters to default
            ArcStyle = {'-k'};
            ArcLabel = '';
            ArcLabelStyle = {'FontSize',10};
            % Check optional input parameters
            sortedsize3 = sort(size(originvec)); % output should be [1 3] for both row and column input originvec
            if sortedsize3(1) ~= 1 && sortedsize3(2) ~= 3
                error('Fourth input vector "originvec" is not a three-dimensional vector')
            end
            originvec = reshape(originvec,3,1); % reshape originvec (in the case it has been provided as a row vector)
            if ~isscalar(ArcRadius) || (isscalar(ArcRadius) && ArcRadius <= 0)
                error('Fifth input "ArcRadius" must be a nonzero, positive scalar quantity')
            end
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            if ~isempty(ArcLabel)
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
            end
        case 6
            
            % Extract optional input parameters
            originvec = varargin{4};
            ArcRadius = varargin{5};
            ArcStyle = varargin{6};
            % Set remaining optional parameters to default
            ArcLabel = '';
            ArcLabelStyle = {'FontSize',10};
            % Check optional input parameters
            sortedsize3 = sort(size(originvec)); % output should be [1 3] for both row and column input originvec
            if sortedsize3(1) ~= 1 && sortedsize3(2) ~= 3
                error('Fourth input vector "originvec" is not a three-dimensional vector')
            end
            originvec = reshape(originvec,3,1); % reshape originvec (in the case it has been provided as a row vector)
            if ~isscalar(ArcRadius) || (isscalar(ArcRadius) && ArcRadius <= 0)
                error('Fifth input "ArcRadius" must be a nonzero, positive scalar quantity')
            end
            if ~iscell(ArcStyle)
                error('Sixth input "ArcStyle" must be a cell array')
            end
            
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            if ~isempty(ArcLabel)
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
            end
        case 7
            
            % Extract optional input parameters
            originvec = varargin{4};
            ArcRadius = varargin{5};
            ArcStyle = varargin{6};
            ArcLabel = varargin{7};
            % Set remaining optional parameters to default
            ArcLabelStyle = {'FontSize',10};
            % Check optional input parameters
            sortedsize3 = sort(size(originvec)); % output should be [1 3] for both row and column input originvec
            if sortedsize3(1) ~= 1 && sortedsize3(2) ~= 3
                error('Fourth input vector "originvec" is not a three-dimensional vector')
            end
            originvec = reshape(originvec,3,1); % reshape originvec (in the case it has been provided as a row vector)
            if ~isscalar(ArcRadius) || (isscalar(ArcRadius) && ArcRadius <= 0)
                error('Fifth input "ArcRadius" must be a nonzero, positive scalar quantity')
            end
            if ~iscell(ArcStyle)
                error('Sixth input "ArcStyle" must be a cell array')
            end
            if ~ischar(ArcLabel)
                error('Seventh input "ArcLabel" must me a character array')
            end
            
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            if ~isempty(ArcLabel)
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
            end
            
            case 8
            
            % Extract optional input parameters
            originvec = varargin{4};
            ArcRadius = varargin{5};
            ArcStyle = varargin{6};
            ArcLabel = varargin{7};
            ArcLabelStyle = varargin{8};
            % Check optional input parameters
            sortedsize3 = sort(size(originvec)); % output should be [1 3] for both row and column input originvec
            if sortedsize3(1) ~= 1 && sortedsize3(2) ~= 3
                error('Fourth input vector "originvec" is not a three-dimensional vector')
            end
            originvec = reshape(originvec,3,1); % reshape originvec (in the case it has been provided as a row vector)
            if ~isscalar(ArcRadius) || (isscalar(ArcRadius) && ArcRadius <= 0)
                error('Fifth input "ArcRadius" must be a nonzero, positive scalar quantity')
            end
            if ~iscell(ArcStyle)
                error('Sixth input "ArcStyle" must be a cell array')
            end
            if ~ischar(ArcLabel)
                error('Seventh input "ArcLabel" must me a character array')
            end
            if ~iscell(ArcLabelStyle)
                error('Eighth input "ArcLabelStyle" must be a cell array')
            end
            
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            if ~isempty(ArcLabel)
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
            end
        case 9
            % Extract optional input parameters
            originvec = varargin{4};
            ArcRadius = varargin{5};
            ArcStyle = varargin{6};
            ArcLabel = varargin{7};
            ArcLabelStyle = varargin{8};
            ArrowedAngle = varargin{9};
            % Check optional input parameters
            sortedsize3 = sort(size(originvec)); % output should be [1 3] for both row and column input originvec
            if sortedsize3(1) ~= 1 && sortedsize3(2) ~= 3
                error('Fourth input vector "originvec" is not a three-dimensional vector')
            end
            originvec = reshape(originvec,3,1); % reshape originvec (in the case it has been provided as a row vector)
            if ~isscalar(ArcRadius) || (isscalar(ArcRadius) && ArcRadius <= 0)
                error('Fifth input "ArcRadius" must be a nonzero, positive scalar quantity')
            end
            if ~iscell(ArcStyle)
                error('Sixth input "ArcStyle" must be a cell array')
            end
            if ~ischar(ArcLabel)
                error('Seventh input "ArcLabel" must me a character array')
            end
            if ~iscell(ArcLabelStyle)
                error('Eighth input "ArcLabelStyle" must be a cell array')
            end
            if ArrowedAngle < 0
                error('Nineth input "ArrowedAngle" must be either 1 for AngleArrow on or 0 for AngleArrow off or a positive scalar value if the ArrowSideLength wants to be set manually')
            end
            
            % Define circumference arc in Angle reference frame
            if ctheta <= 10^(-10) && stheta >= 1 - 10^(-10) % vec1 and vec2 are numerically orthogonal
                ArcLinex = linspace(0,ArcRadius,ceil(ArcDensity/2));
                ArcLiney = linspace(0,ArcRadius,floor(ArcDensity/2));
                ArcSpanAx = [0;ArcRadius;0] + [ArcLinex;zeros(1,length(ArcLinex));zeros(1,length(ArcLinex))]; % horizontal line (3 x ceil(ArcDensity/2) vector)
                ArcSpanAy = [ArcRadius;0;0] + [zeros(1,length(ArcLiney));ArcLiney;zeros(1,length(ArcLiney))]; % vertical line (3 x floor(ArcDensity/2) vector)
                ArcSpanA = [ArcSpanAx,ArcSpanAy];
            else
                ArcSpanA = [ArcRadius*cos(ArcSpan);ArcRadius*sin(ArcSpan);zeros(1,ArcDensity)]; % 3 x ArcDensity matrix
            end
            % Define circumference arc in Plot reference frame
            ArcSpanP = zeros(3,ArcDensity); % preallocate for speed
            for j = 1 : ArcDensity
                ArcSpanP(:,j) = RPA'*ArcSpanA(:,j);
            end
            h = plot3(originvec(1) + ArcSpanP(1,:),originvec(2) + ArcSpanP(2,:),originvec(3) + ArcSpanP(3,:),ArcStyle{:});
            AngleArcLabelvec = originvec + 1.25*ArcSpanP(:,round(ArcDensity/2)); % :,round(ArcDensity/2) component of ArcSpanP
            if ~isempty(ArcLabel)
            tl = text(AngleArcLabelvec(1),AngleArcLabelvec(2),AngleArcLabelvec(3),ArcLabel,ArcLabelStyle{:});
            end
            if ArrowedAngle == 1
                a = 1/10;
                b = 6;
                % f(x) = c*(1 + d*x);
                % f(0) = a;
                % f(2*pi) = b;
                % c = a;
                % d = (b/a - 1)/(2*pi);
                % %%% Symbolic check
                % axis equal
                % syms x real
                % syms a b real
                c = a;
                d = (b/a - 1)/(2*pi);
                % f = c*(1 + d*x)
                % subs(f,x,0)
                % subs(f,x,2*pi)
                ArrowSideLength = c*(1 + d*AngleLength)*(1/10 + ArcRadius/15);
                % ArrowSideLength = 3/(2*pi)*AngleLength*(1/5 + ArcRadius/10);
            elseif ArrowedAngle > 0 && ArrowedAngle ~= 1
                ArrowSideLength = ArrowedAngle;
            end
            ArrowHeadAngle = deg2rad(27);
            OrthogonaluvecA = [cos(ArcSpan(end));sin(ArcSpan(end));0];
            TangentialuvecA = [-sin(ArcSpan(end));cos(ArcSpan(end));0];
            ArrowSide1vecA = ArcSpanA(:,end) + ArrowSideLength*(-cos(ArrowHeadAngle)*TangentialuvecA + sin(ArrowHeadAngle)*OrthogonaluvecA);
            ArrowSide2vecA = ArcSpanA(:,end) + ArrowSideLength*(-cos(ArrowHeadAngle)*TangentialuvecA - sin(ArrowHeadAngle)*OrthogonaluvecA);
            ArrowSide1vecP = RPA'*ArrowSide1vecA;
            ArrowSide2vecP = RPA'*ArrowSide2vecA;
            ar1 = plot3([originvec(1) + ArcSpanP(1,end),originvec(1) + ArrowSide1vecP(1)],[originvec(2) + ArcSpanP(2,end),originvec(2) + ArrowSide1vecP(2)],[originvec(3) + ArcSpanP(3,end),originvec(3) + ArrowSide1vecP(3)],'Color',h.Color,'LineWidth',h.LineWidth,'LineStyle',h.LineStyle);
            ar2 = plot3([originvec(1) + ArcSpanP(1,end),originvec(1) + ArrowSide2vecP(1)],[originvec(2) + ArcSpanP(2,end),originvec(2) + ArrowSide2vecP(2)],[originvec(3) + ArcSpanP(3,end),originvec(3) + ArrowSide2vecP(3)],'Color',h.Color,'LineWidth',h.LineWidth,'LineStyle',h.LineStyle);
    end
    
end
end
