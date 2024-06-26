---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by 0.
--- DateTime: 2019/4/27 13:41
---
local type = type
local pairs = pairs
local table = table
local tableSort = table.sort
local tableInsert = table.insert
local mathMin = math.min
local stringFormat = string.format

XCharacterConfigs = XCharacterConfigs or {}

--角色解放等级
XCharacterConfigs.GrowUpLevel = {
    New = 1, -- 新兵
    Lower = 2, -- 低级
    Middle = 3, -- 中级
    Higher = 4, -- 高级
    End = 4,
}

-- 推荐类型
XCharacterConfigs.RecommendType = {
    Character = 1, --推荐角色
    Equip = 2, --推荐装备
}

XCharacterConfigs.XUiCharacter_Camera = {
    MAIN = 0,
    LEVEL = 1,
    GRADE = 2,
    QULITY = 3,
    SKILL = 4,
    EXCHANGE = 5
}

XCharacterConfigs.MAX_QUALITY_STAR = 10

--角色终阶解放技能ID约定配置
XCharacterConfigs.MAX_LEBERATION_SKILL_POS_INDEX = 13

local TABLE_CHARACTER_PATH = "Share/Character/Character.tab"
local TABLE_CHARACTER_RES_PATH = "Share/Character/CharacterRes.tab"
local TABLE_LEVEL_UP_TEMPLATE_PATH = "Share/Character/LevelUpTemplate/"
local TABLE_CHARACTER_QUALITY_FRAGMENT_PATH = "Share/Character/Quality/CharacterQualityFragment.tab"
local TABLE_CHARACTER_QUALITY_PATH = "Share/Character/Quality/CharacterQuality.tab"
local TABLE_CHARACTER_GRADE_PATH = "Share/Character/Grade/CharacterGrade.tab"
local TABLE_NPC_TYPE_ICON_PATH = "Share/Character/NpcTypeIcon.tab"
local TABLE_CHARACTER_SKILL = "Share/Character/Skill/CharacterSkill.tab"
local TABLE_CHARACTER_DETAIL = "Client/Character/CharacterDetail.tab"
local TABLE_CHARACTER_SKILL_TEACH = "Client/Character/CharacterSkillTeach.tab"
local TABLE_CHARACTER_ELEMENT_CONFIG = "Client/Character/CharacterElement.tab"
local TABLE_CHARACTER_SKILL_POS = "Share/Character/Skill/CharacterSkillPos.tab"
local TABLE_CHARACTER_SKILL_GRADE = "Share/Character/Skill/CharacterSkillUpgrade.tab"
local TABLE_CHARACTER_SKILL_LEVEL = "Share/Character/Skill/CharacterSkillLevelEffect.tab"
local TABLE_CHARACTER_GRAPH_INFO = "Client/Character/CharacterGraph.tab"
local TABLE_CHARACTER_SKILL_POOL = "Share/Character/Skill/CharacterSkillPool.tab"
local TABLE_CHARACTER_DETAIL_PARNER = "Client/Character/CharacterRecommend.tab"
local TABLE_CHARACTER_DETAIL_EQUIP = "Client/Character/EquipRecommend.tab"
local TABLE_CHARACTER_RECOMMEND_TAB_CONFIG = "Client/Character/CharacterTabId.tab"
local TABLE_CHARACTER_QUALITY_ICON_PATH = "Client/Character/CharacterQualityIcon.tab"
local TABLE_NPC_PATH = "Share/Fight/Npc/Npc"
local TABLE_CHARACTER_LIBERATION_PATH = "Client/Character/CharacterLiberation.tab"

-- 配置相关
local CharacterTemplates = {}               -- 角色配置
local LevelUpTemplates = {}                 -- 升级模板
local CharQualityTemplates = {}             -- 角色品质配置
local CharQualityFragmentTemplates = {}     -- 品质对应碎片
local CharQualityIconTemplates = {}         -- 角色品质图标
local CharGradeTemplates = {}               -- 角色改造配置
local CharBorderTemplates = {}              -- 角色边界属性
local NpcTypeIconTemplates = {}             -- npc类型图标配置
local CharSkillTemplates = {}               -- 角色主技能配置
local CharSkillIdMap = {}                   -- 角色主技能id
local SubSkillMinMaxLevelTemplates = {}     -- 副技能最小最大等级配置
local CharDetailTemplates = {}              -- 角色详细
local CharTeachSkill = {}                   -- 角色技能教学
local CharElementTemplates = {}             -- 角色元素配置
local CharacterSkillDictTemplates = {}      -- 角色技能组配置 
local SkillGradeConfig = {}                 -- 角色技能升级表
local SkillPosConfig = {}                   -- 角色技能大组显示配置
local SkillLevelConfig = {}                 -- 角色技能升级魔法属性配置表
local CharSkillTemplates = {}               -- 角色子技能配置
local CharGraphTemplates = {}               -- 角色六位图配置
local CharSkillLevelDict = {}               -- 角色技能Id，等级Id的属性表Map
local CharSkillLevelEffectDict = {}         -- 角色技能Id, 等级Id的升级表Map
local CharSkillPoolSkillIdDic = {}          -- 角色技能共鸣池SkillId映射技能信息字典
local CharPoolIdToSkillInfoDic = {}         -- 角色技能共鸣池PoolId映射技能信息字典
local CharSkillIdToCharacterIdDic = {}      -- SkillId映射CharacterId字典
local ItemIdToCharacterIdDic = {}           -- 角色碎片Id映射CharacterId字典
local CharLiberationTemplates = {}          -- 角色解放配置
local NpcTemplates = {}                     -- npc配置表
local CharMaxLiberationSkillIdDic = {}      -- 角色终阶解放技能Id字典

local CharacterRecommendTemplates   --角色推荐表
local EquipRecommendTemplates       --装备推荐表
local CharacterTabToVoteGroupMap    --角色标签转投票组表
local CharacterTemplatesCount       --角色总数量

local CompareQuality = function(templateId, quality)
    local template = CharBorderTemplates[templateId]
    if not template then
        return
    end

    if not template.MinQuality or template.MinQuality > quality then
        template.MinQuality = quality
    end

 
 
    if not template.MaxQuality or template.MaxQuality < quality then
        template.MaxQuality = quality
    end
end

local CompareGrade = function(templateId, grade)
    local template = CharBorderTemplates[templateId]
    if not template then
        return
    end

    if not template.MinGrade or template.MinGrade > grade then
        template.MinGrade = grade
    end

    if not template.MaxGrade or template.MaxGrade < grade then
        template.MaxGrade = grade
    end
end

local InitCharQualityConfig = function()
    -- 品质碎片配置
    CharQualityFragmentTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_QUALITY_FRAGMENT_PATH, XTable.XTableCharacterQualityFragment, "Quality")

    -- 角色品质对应配置
    local tab = XTableManager.ReadByIntKey(TABLE_CHARACTER_QUALITY_PATH, XTable.XTableCharacterQuality, "Id")
    for _, config in pairs(tab) do
        if not CharQualityTemplates[config.CharacterId] then
            CharQualityTemplates[config.CharacterId] = {}
        end
        CharQualityTemplates[config.CharacterId][config.Quality] = config
        CompareQuality(config.CharacterId, config.Quality)
    end

    CharQualityIconTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_QUALITY_ICON_PATH, XTable.XTableCharacterQualityIcon, "Quality")
end

local InitCharLiberationConfig = function()
    local tab = XTableManager.ReadByIntKey(TABLE_CHARACTER_LIBERATION_PATH, XTable.XTableCharacterLiberation, "Id")
    for _, config in pairs(tab) do
        if not CharLiberationTemplates[config.CharacterId] then
            CharLiberationTemplates[config.CharacterId] = {}
        end
        CharLiberationTemplates[config.CharacterId][config.GrowUpLevel] = config
    end
end

local InitCharGradeConfig = function()
    -- 角色改造数据
    local tab = XTableManager.ReadByIntKey(TABLE_CHARACTER_GRADE_PATH, XTable.XTableCharacterGrade, "Id")
    for _, config in pairs(tab) do
        if not CharGradeTemplates[config.CharacterId] then
            CharGradeTemplates[config.CharacterId] = {}
        end

        CharGradeTemplates[config.CharacterId][config.Grade] = config
        CompareGrade(config.CharacterId, config.Grade)
    end
end

local InitCharLevelConfig = function()
    local paths = CS.XTableManager.GetPaths(TABLE_LEVEL_UP_TEMPLATE_PATH)
    XTool.LoopCollection(paths, function(path)
        local key = tonumber(XTool.GetFileNameWithoutExtension(path))
        LevelUpTemplates[key] = XTableManager.ReadByIntKey(path, XTable.XTableEquipLevelUp, "Level")
    end)
end

local InitMaxLevelConfig = function()
    for id, template in pairs(CharacterTemplates) do
        local levelTemplate = LevelUpTemplates[template.LevelUpTemplateId]
        if not levelTemplate then
            XLog.Error("InitMaxLevelConfig error: can not found level up template, characterId is " .. id)
            return
        end

        CharBorderTemplates[id].MinLevel = 1
        CharBorderTemplates[id].MaxLevel = #levelTemplate
    end
end

local IntCharSubSkillConfig = function()
    SkillGradeConfig = XTableManager.ReadByIntKey(TABLE_CHARACTER_SKILL_GRADE, XTable.XTableCharacterSkillUpgrade, "Id")
    SkillPosConfig = XTableManager.ReadByIntKey(TABLE_CHARACTER_SKILL_POS, XTable.XTableCharacterPos, "CharacterId")
    CharSkillTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_SKILL, XTable.XTableCharacterSkill, "CharacterId")
    local skillLevelConfig = XTableManager.ReadByIntKey(TABLE_CHARACTER_SKILL_LEVEL, XTable.XTableCharacterSkillLevelEffect, "Id")

    for _, config in pairs(CharSkillTemplates) do
        local characterId = config.CharacterId

        if not CharacterSkillDictTemplates[characterId] then
            CharacterSkillDictTemplates[characterId] = {}
        end

        for index, skillId in pairs(config.SkillId) do
            local pos = config.Pos[index]
            if not CharacterSkillDictTemplates[characterId][pos] then
                CharacterSkillDictTemplates[characterId][pos] = {}
            end
            table.insert(CharacterSkillDictTemplates[characterId][pos], skillId)

            CharSkillIdToCharacterIdDic[skillId] = characterId

            if index == XCharacterConfigs.MAX_LEBERATION_SKILL_POS_INDEX then
                CharMaxLiberationSkillIdDic[characterId] = skillId
            end
        end
    end

    for k, v in pairs(SkillGradeConfig) do
        if not CharSkillLevelDict[v.SkillId] then
            CharSkillLevelDict[v.SkillId] = {}
        end
        CharSkillLevelDict[v.SkillId][v.Level] = k
    end

    for _, v in pairs(skillLevelConfig) do
        if not CharSkillLevelEffectDict[v.SkillId] then
            CharSkillLevelEffectDict[v.SkillId] = {}
        end
        CharSkillLevelEffectDict[v.SkillId][v.Level] = v
    end

    --初始化技能的最小，最大等级
    SubSkillMinMaxLevelTemplates = {}
    for k, v in pairs(SkillGradeConfig) do
        local skillId = v.SkillId
        if not SubSkillMinMaxLevelTemplates[skillId] then
            SubSkillMinMaxLevelTemplates[skillId] = {}
            SubSkillMinMaxLevelTemplates[skillId].Min = v.Level
            SubSkillMinMaxLevelTemplates[skillId].Max = v.Level
        end

        if v.Level < SubSkillMinMaxLevelTemplates[skillId].Min then
            SubSkillMinMaxLevelTemplates[skillId].Min = v.Level
        end

        if v.Level > SubSkillMinMaxLevelTemplates[skillId].Max then
            SubSkillMinMaxLevelTemplates[skillId].Max = v.Level
        end
    end
end

local InitCharacterSkillPoolConfig = function()
    CharSkillPoolSkillIdDic = {}

    local skillPoolTemplate = XTableManager.ReadByIntKey(TABLE_CHARACTER_SKILL_POOL, XTable.XTableCharacterSkillPool, "Id")
    for _, v in pairs(skillPoolTemplate) do
        local skillInfo = {
            SkillId = v.SkillId,
            Icon = v.Icon,
            Name = v.Name,
            Description = v.Description,
        }

        CharSkillPoolSkillIdDic[v.SkillId] = skillInfo
        CharPoolIdToSkillInfoDic[v.PoolId] = CharPoolIdToSkillInfoDic[v.PoolId] or {}

        tableInsert(CharPoolIdToSkillInfoDic[v.PoolId], skillInfo)
    end
end

local function voteNumSort(dataA, dataB)
    local voteA = XDataCenter.VoteManager.GetVote(dataA.Id).VoteNum
    local voteB = XDataCenter.VoteManager.GetVote(dataB.Id).VoteNum
    return voteA > voteB
end

local InitRecommendConfig = function(templates)
    CharacterTabToVoteGroupMap = {}
    for _, config in pairs(templates) do
        local typeMap = CharacterTabToVoteGroupMap[config.CharacterId]
        if not typeMap then
            typeMap = {}
            CharacterTabToVoteGroupMap[config.CharacterId] = typeMap
        end

        local tabMap = typeMap[config.RecommendType]
        if not tabMap then
            tabMap = {}
            typeMap[config.RecommendType] = tabMap
        end

        tabMap[config.TabId] = config
    end
end

function XCharacterConfigs.Init()
    CharacterTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_PATH, XTable.XTableCharacter, "Id")
    CharDetailTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_DETAIL, XTable.XTableCharDetail, "Id")
    CharTeachSkill = XTableManager.ReadByIntKey(TABLE_CHARACTER_SKILL_TEACH, XTable.XTableCharacterSkillTeach, "Id")
    CharElementTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_ELEMENT_CONFIG, XTable.XTableCharacterElement, "Id")
    CharGraphTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_GRAPH_INFO, XTable.XTableGraph, "Id")
    CharacterRecommendTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_DETAIL_PARNER, XTable.XTableCharacterRecommend, "Id")
    EquipRecommendTemplates = XTableManager.ReadByIntKey(TABLE_CHARACTER_DETAIL_EQUIP, XTable.XTableEquipRecommend, "Id")
    NpcTemplates = XTableManager.ReadByIntKey(TABLE_NPC_PATH, XTable.XTableNpc, "Id")

    local templates = XTableManager.ReadByIntKey(TABLE_CHARACTER_RECOMMEND_TAB_CONFIG, XTable.XTableCharacterTabId, "Id")
    InitRecommendConfig(templates)

    local characterTemplatesCount = 0
    for id, template in pairs(CharacterTemplates) do
        CharBorderTemplates[id] = {}
        ItemIdToCharacterIdDic[template.ItemId] = id
        characterTemplatesCount = characterTemplatesCount + 1
    end
    CharacterTemplatesCount = characterTemplatesCount

    InitCharLevelConfig()
    InitCharQualityConfig()
    InitCharLiberationConfig()
    InitCharGradeConfig()
    InitMaxLevelConfig()
    IntCharSubSkillConfig()
    InitCharacterSkillPoolConfig()

    CharBorderTemplates = XReadOnlyTable.Create(CharBorderTemplates)
    ItemIdToCharacterIdDic = XReadOnlyTable.Create(ItemIdToCharacterIdDic)

    NpcTypeIconTemplates = XTableManager.ReadByIntKey(TABLE_NPC_TYPE_ICON_PATH, XTable.XTableNpcTypeIcon, "Type")
end

function XCharacterConfigs.GetCharacterSkills(templateId)
    local character = XDataCenter.CharacterManager.GetCharacter(templateId)
    if not CharacterSkillDictTemplates[templateId] then
        XLog.Error(" XCharacterConfigs.GetCharacterSkills template is null " .. templateId)
        return
    end
    local skills = {}
    for i = 1, 5 do
        skills[i] = {}
        skills[i].subSkills = {}
        skills[i].config = {}
        skills[i].totalSkillPoint = 0
        skills[i].config.Pos = i

        if not SkillPosConfig[templateId] then
            XLog.Error(" XCharacterConfigs.GetCharacterSkills is null " .. templateId)
        else
            skills[i].Icon = SkillPosConfig[templateId].MainSkillIcon[i]
            skills[i].Name = SkillPosConfig[templateId].MainSkillName[i]
            skills[i].TypeDes = SkillPosConfig[templateId].MainSkillType[i]
            skills[i].SkillIdList = CharacterSkillDictTemplates[templateId][i]
            skills[i].TotalLevel = 0

            if skills[i].SkillIdList then
                for k, v in pairs(skills[i].SkillIdList) do
                    local skillCo = {}
                    skillCo.SubSkillId = v
                    skillCo.totalSkillPoint = 0
                    skillCo.Level = character.SkillLevel[v]

                    if not skillCo.Level then
                        skillCo.Level = 0
                    end

                    local tabId = CharSkillLevelDict[v][skillCo.Level]
                    if tabId then
                        skillCo.config = SkillGradeConfig[tabId]
                    end

                    skills[i].TotalLevel = skills[i].TotalLevel + skillCo.Level

                    table.insert(skills[i].subSkills, skillCo)
                end
            end
        end
    end

    return skills
end

function XCharacterConfigs.GetCharDetailParnerTemplate(templateId)
    local config = CharacterRecommendTemplates[templateId]
    if not config then
        XLog.Error("XCharacterConfigs.GetCharacterRecommendTemplate error. Recommend id not exist. recommendId = " .. tostring(templateId))
    end
    return config
end

function XCharacterConfigs.GetCharacterRecommendListByIds(ids)
    local list = {}
    for _, id in ipairs(ids) do
        local config = XCharacterConfigs.GetCharDetailParnerTemplate(id)
        if config then
            table.insert(list, config)
        end
    end

    tableSort(list, voteNumSort)

    return list
end

function XCharacterConfigs.GetCharDetailEquipTemplate(templateId)
    local config = EquipRecommendTemplates[templateId]
    if not config then
        XLog.Error("XCharacterConfigs.GetEquipRecommendTemplate error. Recommend id not exist. recommendId = " .. tostring(templateId))
    end
    return config
end

function XCharacterConfigs.GetEquipRecommendListByIds(ids)
    local list = {}
    for _, id in ipairs(ids) do
        local config = XCharacterConfigs.GetCharDetailEquipTemplate(id)
        if config then
            table.insert(list, config)
        end
    end

    tableSort(list, voteNumSort)

    return list
end

function XCharacterConfigs.GetRecommendTabList(characterId, recommendType)
    local tabIdList = {}
    local typeMap = CharacterTabToVoteGroupMap[characterId]
    if typeMap then
        local tabMap = typeMap[recommendType]
        if tabMap then
            for recommendType, v in pairs(tabMap) do
                table.insert(tabIdList, recommendType)
            end
        end
    end

    tableSort(tabIdList)
    return tabIdList
end

function XCharacterConfigs.GetRecommendTabTemplate(characterId, tabId, recommendType)
    local typeMap = CharacterTabToVoteGroupMap[characterId]
    if not typeMap then
        XLog.Error("XCharacterConfigs.GetRecommendTabTemplate error. characterId is not found: " .. tostring(characterId))
        return nil
    end

    local tabMap = typeMap[recommendType]
    if not tabMap then
        XLog.Error("XCharacterConfigs.GetRecommendTabTemplate error. recommendType is not found: " .. tostring(recommendType))
        return nil
    end

    local config = tabMap[tabId]
    if not config then
        XLog.Error("XCharacterConfigs.GetRecommendTabTemplate error. tabId is not found: " .. tostring(tabId))
        return nil
    end

    return config
end

function XCharacterConfigs.GetRecommendGroupId(characterId, tabId, recommendType)
    local typeMap = CharacterTabToVoteGroupMap[characterId]
    if not typeMap then
        XLog.Error(" XCharacterConfigs.GetRecommendGroupId error. characterId is not found: " .. tostring(characterId))
        return
    end

    local tabMap = typeMap[recommendType]
    if not tabMap then
        XLog.Error(" XCharacterConfigs.GetRecommendGroupId error. can not find recommend type: " .. tostring(recommendType))
        return
    end

    local config = tabMap[tabId]
    if not config then
        XLog.Error(" XCharacterConfigs.GetRecommendGroupId error. tabId is not found: " .. tostring(tabId))
        return
    end

    return config.GroupId
end

function XCharacterConfigs.GetCharacterTemplate(templateId)
    local template = CharacterTemplates[templateId]
    if template == nil then
        XLog.Error("XCharacterConfigs.GetCharacterTemplate error: can not found template, templateId = " .. templateId)
        return
    end

    return template
end

function XCharacterConfigs.GetCharacterTemplates()
    return CharacterTemplates
end

function XCharacterConfigs.GetCharacterTemplatesCount()
    return CharacterTemplatesCount
end

function XCharacterConfigs.GetAllCharElments()
    return CharElementTemplates
end

function XCharacterConfigs.GetCharElment(templateId)
    local template = CharElementTemplates[templateId]
    if template == nil then
        XLog.Error("XCharacterConfigs.GetCharElment error: can not found template, templateId = " .. templateId)
        return
    end
    return template
end


function XCharacterConfigs.GetCharacterBorderTemplate(templateId)
    local template = CharBorderTemplates[templateId]
    if template == nil then
        XLog.Error("XCharacterConfigs.GetCharacterBorderTemplate error: can not found template, templateId = " .. templateId)
        return
    end

    return template
end

function XCharacterConfigs.GetCharacterDefaultEquipId(templateId)
    local template = XCharacterConfigs.GetCharacterTemplate(templateId)
    if template then
        return template.EquipId
    end
end

function XCharacterConfigs.GetQualityTemplate(templateId, quality)
    if templateId == nil or quality == nil then
        XLog.Error("XCharacterConfigs.GetQualityTemplate error: params is nil")
        return
    end

    if quality <= 0 then
        XLog.Error("XCharacterConfigs.GetQualityTemplate error: quality = " .. quality)
        return
    end

    local config = CharQualityTemplates[templateId]
    if not config then
        XLog.Error("XCharacterConfigs.GetQualityTemplate error: unknown character, templateId = " .. templateId)
        return
    end

    local qualityConfig = config[quality]
    if qualityConfig == nil then
        XLog.Error("XCharacterConfigs.GetQualityTemplate error: unknown character, templateId = " .. templateId .. " quality = " .. quality)
        return
    end

    return qualityConfig
end

function XCharacterConfigs.GetCharNpcId(templateId, quality)
    local qualityConfig = XCharacterConfigs.GetQualityTemplate(templateId, quality)
    if not qualityConfig then
        return
    end

    return qualityConfig.NpcId
end

function XCharacterConfigs.GetNpcTypeIcon(type)
    if not type then
        XLog.Error("XCharacterConfigs.GetNpcTypeIcon error: type is nil")
        return
    end

    local config = NpcTypeIconTemplates[type]
    if not config then
        XLog.Error("XCharacterConfigs.GetNpcTypeIcon error: can not found config, type is " .. type)
        return
    end

    return config.Icon
end

function XCharacterConfigs.GetNpcTypeIconTranspose(type)
    if not type then
        XLog.Error("XCharacterConfigs.GetNpcTypeIconTranspose error: type is nil")
        return
    end

    local config = NpcTypeIconTemplates[type]
    if not config then
        XLog.Error("XCharacterConfigs.GetNpcTypeIconTranspose error: can not found config, type is " .. type)
        return
    end

    return config.IconTranspose
end

function XCharacterConfigs.GetNpcTypeTemplate(typeId)
    if not typeId then
        XLog.Error("XCharacterConfigs.GetNpcTypeIcon error: type is nil")
        return
    end

    local config = NpcTypeIconTemplates[typeId]
    if not config then
        XLog.Error("XCharacterConfigs.GetNpcTypeIcon error: can not found config, type is " .. typeId)
        return
    end

    return config
end

function XCharacterConfigs.GetCharacterEquipType(templateId)
    return CharacterTemplates[templateId].EquipType
end

function XCharacterConfigs.GetNpcPromotedAttribByQuality(templateId, quality)
    local npcId = XCharacterConfigs.GetCharNpcId(templateId, quality)
    local npcTemplate = CS.XNpcManager.GetNpcTemplate(npcId)
    return XAttribManager.GetPromotedAttribs(npcTemplate.PromotedId)
end

-- 卡牌信息begin --
function XCharacterConfigs.GetCharacterName(templateId)
    return CharacterTemplates[templateId].Name
end

function XCharacterConfigs.GetCharacterTradeName(templateId)
    return CharacterTemplates[templateId].TradeName
end

function XCharacterConfigs.GetCharacterFullNameStr(templateId)
    local name = XCharacterConfigs.GetCharacterName(templateId)
    local tradeName = XCharacterConfigs.GetCharacterTradeName(templateId)
    return CS.XTextManager.GetText("CharacterFullName", name, tradeName)
end

function XCharacterConfigs.GetCharacterIntro(templateId)
    return CharacterTemplates[templateId].Intro
end

function XCharacterConfigs.GetCharacterPriority(templateId)
    return CharacterTemplates[templateId].Priority
end

function XCharacterConfigs.GetCharacterEmotionIcon(templateId)
    return CharacterTemplates[templateId].EmotionIcon
end

function XCharacterConfigs.GetCharacterCaptainSkill(templateId)
    return CharacterTemplates[templateId].CaptainSkillId
end

function XCharacterConfigs.GetCharacterStoryChapterId(templateId)
    return CharacterTemplates[templateId].StoryChapterId
end

function XCharacterConfigs.GetCharacterCodeStr(templateId)
    return CharacterTemplates[templateId].Code
end

function XCharacterConfigs.GetCharacterIsomer(templateId)
    return CharacterTemplates[templateId].Isomer
end

--首次获得弹窗
function XCharacterConfigs.GetCharacterNeedFirstShow(templateId)
    return CharacterTemplates[templateId].NeedFirstShow
end
-- 卡牌信息end --
-- 升级相关begin --
function XCharacterConfigs.GetCharMaxLevel(tempalteId)
    if not tempalteId then
        XLog.Error("XCharacterConfigs.GetCharMaxLevel error: templateId is nil")
        return
    end

    return CharBorderTemplates[tempalteId].MaxLevel
end

function XCharacterConfigs.GetNextLevelExp(templateId, level)
    local levelUpTemplateId = CharacterTemplates[templateId].LevelUpTemplateId
    local levelUpTemplate = LevelUpTemplates[levelUpTemplateId]

    return levelUpTemplate[level].Exp
end

function XCharacterConfigs.GetLevelUpTemplate(levelUpTemplateId)
    return LevelUpTemplates[levelUpTemplateId]
end

-- 升级相关end --
-- 品质相关begin --
function XCharacterConfigs.GetCharQualityIcon(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetCharQualityIcon error: quality is " .. quality)
        return
    end

    local template = CharQualityIconTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetCharQualityIcon error: can not found template, quality is " .. quality)
        return
    end

    return template.Icon
end

function XCharacterConfigs.GetCharacterQualityIcon(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetCharacterQualityIcon error: quality is " .. quality)
        return
    end

    local template = CharQualityIconTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetCharacterQualityIcon error: can not found template, quality is " .. quality)
        return
    end

    return template.IconCharacter
end

function XCharacterConfigs.GetCharQualityIconGoods(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetCharQualityIconGoods error: quality is " .. quality)
        return
    end

    local template = CharQualityIconTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetCharQualityIconGoods error: can not found template, quality is " .. quality)
        return
    end

    return template.IconGoods
end

function XCharacterConfigs.GetCharQualityDesc(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetCharQualityIcon error: quality is " .. quality)
        return
    end

    local template = CharQualityIconTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetCharQualityIcon error: can not found template, quality is " .. quality)
        return
    end

    return template.Desc
end

function XCharacterConfigs.GetDecomposeCount(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetDecomposeCount error: quality is " .. quality)
        return
    end

    local template = CharQualityFragmentTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetDecomposeCount error: can not found template, quality is " .. quality)
        return
    end

    return template.DecomposeCount
end

function XCharacterConfigs.GetComposeCount(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetComposeCount error: quality is " .. quality)
        return
    end


    local template = CharQualityFragmentTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetComposeCount error: can not found template, quality is " .. quality)
        return
    end

    return template.ComposeCount
end

function XCharacterConfigs.GetStarUseCount(quality, star)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetStarUseCount error: quality is " .. quality)
        return
    end

    if not star or (star < 1 or star > XCharacterConfigs.MAX_QUALITY_STAR) then
        XLog.Error("XCharacterConfigs.GetStarUseCount error: star is " .. star)
        return
    end

    local template = CharQualityFragmentTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetStarUseCount error: can not found template, quality is " .. quality)
        return
    end

    local starUseCount = template.StarUseCount
    return starUseCount[star] or 0
end

function XCharacterConfigs.GetPromoteUseCoin(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetPromoteUseCoin error: quality is " .. quality)
        return
    end
    local template = CharQualityFragmentTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetPromoteUseCoin error: can not found template, quality is " .. quality)
        return
    end
    return template.PromoteUseCoin
end

function XCharacterConfigs.GetPromoteItemId(quality)
    if not quality or quality < 1 then
        XLog.Error("XCharacterConfigs.GetPromoteItemId error: quality is " .. quality)
        return
    end
    local template = CharQualityFragmentTemplates[quality]
    if not template then
        XLog.Error("XCharacterConfigs.GetPromoteItemId error: can not found template, quality is " .. quality)
        return
    end
    return template.PromoteItemId
end

function XCharacterConfigs.GetCharStarAttribId(templateId, quality, star)
    if not templateId then
        XLog.Error("XCharacterConfigs.GetCharStarAttribId error: templateId is " .. templateId)
        return
    end

    if not quality or (quality < 1 or quality > XCharacterConfigs.GetCharMaxQuality(templateId)) then
        XLog.Error("XCharacterConfigs.GetCharStarAttribId error: quality is " .. quality)
        return
    end

    if not star or (star < 1 or star > XCharacterConfigs.MAX_QUALITY_STAR) then
        XLog.Error("XCharacterConfigs.GetCharStarAttribId error: star is " .. star)
        return
    end

    local template = CharQualityTemplates[templateId]
    if not template[quality] then
        XLog.Error("XCharacterConfigs.GetCharQualityStarAttr error: char has not quality is " .. quality)
        return
    end

    local attrIds = template[quality].AttrId

    if attrIds and attrIds[star] then
        if attrIds[star] > 0 then
            return attrIds[star]
        end
    end
end

function XCharacterConfigs.GetCharStarAttribs(templateId, quality, star)
    if not templateId and not quality and not star then
        XLog.Error("XCharacterConfigs.GetCharStarAttribs: templateId, quality, star")
        return
    end

    if star < XCharacterConfigs.MAX_QUALITY_STAR then
        local attrId = XCharacterConfigs.GetCharStarAttribId(templateId, quality, star + 1)
        if not attrId then
            XLog.Error("XCharacterConfigs.GetCharStarAttribs: attrId nil" .. templateId .. " " .. quality)
            return
        end

        return XAttribManager.GetBaseAttribs(attrId)
    end
end

function XCharacterConfigs.GetCharMinQuality(templateId)
    if not templateId then
        XLog.Error("XCharacterConfigs.GetCharMinQuality error: templateId is nil")
        return
    end

    if not CharBorderTemplates[templateId] then
        XLog.Error("XCharacterConfigs.GetCharMinQuality is not exist" .. templateId)
        return
    end

    return CharBorderTemplates[templateId].MinQuality
end

function XCharacterConfigs.GetCharMaxQuality(templateId)
    if not templateId then
        XLog.Error("XCharacterConfigs.GetCharMaxQuality error: templateId is nil")
        return
    end

    return CharBorderTemplates[templateId].MaxQuality
end

function XCharacterConfigs.GetCharGraphTemplate(graphId)
    local template = CharGraphTemplates[graphId]
    if not template then
        XLog.Error(" XCharacterConfigs.GetCharGraphTemplate is not exist " .. graphId)
        return
    end
    return template
end
-- 品质相关end --
-- 改造相关begin --
function XCharacterConfigs.GetCharMaxGrade(templateId)
    return CharBorderTemplates[templateId].MaxGrade
end

function XCharacterConfigs.GetCharMinGrade(templateId)
    return CharBorderTemplates[templateId].MinGrade
end

function XCharacterConfigs.GetQualityUpgradeItemId(templateId, grade)
    return CharGradeTemplates[templateId][grade].UseItemId
end

function XCharacterConfigs.GetCharGradeIcon(templateId, grade)
    return CharGradeTemplates[templateId][grade].GradeIcon
end

function XCharacterConfigs.GetGradeTemplates(templateId, grade)
    return CharGradeTemplates[templateId][grade]
end

function XCharacterConfigs.GetCharGradeName(templateId, grade)
    grade = grade or XCharacterConfigs.GetCharMinGrade(templateId)
    return CharGradeTemplates[templateId][grade].GradeName
end

function XCharacterConfigs.GetCharGradeUseMoney(templateId, grade)
    local consumeItem = {}
    consumeItem.Id = CharGradeTemplates[templateId][grade].UseItemKey
    consumeItem.Count = CharGradeTemplates[templateId][grade].UseItemCount
    return consumeItem
end

function XCharacterConfigs.GetCharGradeAttrId(templateId, grade)
    if not templateId or not grade then
        XLog.Error("XCharacterConfigs.GetCharGradeAttrId error: templateId or grade is nil")
        return
    end

    local template = CharGradeTemplates[templateId]
    if not template then
        return
    end

    if template[grade] then
        if template[grade].AttrId and template[grade].AttrId > 0 then
            return template[grade].AttrId
        end
    end
end

function XCharacterConfigs.GetNeedPartsGrade(templateId, grade)
    return CharGradeTemplates[templateId][grade].PartsGrade
end

function XCharacterConfigs.GetSubSkillMinMaxLevel(subSkillId)
    return SubSkillMinMaxLevelTemplates[subSkillId]
end

function XCharacterConfigs.GetCharTeachById(charId)
    return CharTeachSkill[charId]
end

--战中设置
function XCharacterConfigs.GetCharTeachIconById(charId)
    local cfg = CharTeachSkill[charId]
    return cfg and cfg.TeachIcon or nil
end

--战中设置
function XCharacterConfigs.GetCharTeachDescriptionById(charId)
    local cfg = CharTeachSkill[charId]
    return cfg and cfg.Description or nil
end

function XCharacterConfigs.GetCharTeachStageIdById(charId)
    local cfg = CharTeachSkill[charId]
    return cfg and cfg.StageId
end

function XCharacterConfigs.GetCharTeachWebUrlById(charId)
    local cfg = CharTeachSkill[charId]
    return cfg and cfg.WebUrl
end

function XCharacterConfigs.GetSubSkillAbility(subSkillId, level)
    local config = XCharacterConfigs.GetSkillLevelEffectTemplate(subSkillId, level)
    return config and config.Ability or 0
end

function XCharacterConfigs.GetResonanceSkillAbility(subSkillId, level)
    local config = XCharacterConfigs.GetSkillLevelEffectTemplate(subSkillId, level)
    return config and config.ResonanceAbility or 0
end

function XCharacterConfigs.GetSkillLevelEffectTemplate(skillId, level)
    local subSkills = CharSkillLevelEffectDict[skillId]
    if (not subSkills) then
        XLog.Error("XCharacterConfigs.GetSkillLevelEffectTemplate error: unknown skill, skill Id = " .. skillId)
        return
    end

    local config = subSkills[level]
    if not config then
        XLog.Error(" XCharacterConfigs.GetSkillLevelEffectTemplate " .. skillId .. " " .. level .. " " .. level)
        return
    end

    return config
end

--==============================--
--desc: 获取队长技能描述
--@characterId: 卡牌数据
--@return 技能Data
--==============================--
function XCharacterConfigs.GetCaptainSkillInfo(characterId, skillLevel)
    local captianSkillId = XCharacterConfigs.GetCharacterCaptainSkill(characterId)

    if not skillLevel then
        local config = SubSkillMinMaxLevelTemplates[captianSkillId]
        if not config then
            XLog.Error(" XCharacterConfigs.GetCaptainSkillInfo SubSkillMinMaxLevelTemplates is not exist " .. captianSkillId .. " " .. characterId)
            return
        end
        skillLevel = config.Min
    end

    local tab = CharSkillLevelDict[captianSkillId][skillLevel]
    local config = SkillGradeConfig[tab]
    if not config then
        XLog.Error(" XCharacterConfigs.GetCaptainSkillInfo GradeInfo is null " .. characterId .. " " .. captianSkillId .. " " .. skillLevel .. " " .. tab)
    end

    return config
end

function XCharacterConfigs.GetSkillGradeConfig(subSkillId, subSkillLevel)
    local skillLevelDict = CharSkillLevelDict[subSkillId]
    if not skillLevelDict then
        return
    end

    local tabId = skillLevelDict[subSkillLevel]
    if not tabId then
        return
    end

    return SkillGradeConfig[tabId]
end

function XCharacterConfigs.GetCharcterIdByFragmentItemId(itemId)
    return ItemIdToCharacterIdDic[itemId]
end

-------------角色详细相关------------------
function XCharacterConfigs.GetCharDetailTemplate(templateId)
    return CharDetailTemplates[templateId]
end

function XCharacterConfigs.GetCharacterSkillPoolSkillInfo(skillId)
    if not CharSkillPoolSkillIdDic[skillId] then
        XLog.Error("XCharacterConfigs.GetCharacterSkillPoolSkillInfo error: can not find template in CharSkillPoolSkillIdDic,skillId is" .. skillId)
    end

    return CharSkillPoolSkillIdDic[skillId]
end

function XCharacterConfigs.GetCharacterSkillPoolSkillInfos(poolId, characterId)
    local skillInfos = {}

    if not CharPoolIdToSkillInfoDic[poolId] then return skillInfos end
    for _, skillInfo in pairs(CharPoolIdToSkillInfoDic[poolId]) do
        local skillId = skillInfo.SkillId

        if CharSkillIdToCharacterIdDic[skillId] and CharSkillIdToCharacterIdDic[skillId] == characterId then
            tableInsert(skillInfos, skillInfo)
        end
    end

    return skillInfos
end

function XCharacterConfigs.GetNpcTemplate(id)
    local template = NpcTemplates[id]
    if not template then
        XLog.Error("XCharacterConfigs.GetNpcTemplate error: can not found template, id is " .. id)
        return
    end

    return template
end

function XCharacterConfigs.GetCharQualityTemplates()
    return CharQualityTemplates
end

function XCharacterConfigs.GetCharGradeTemplates()
    return CharGradeTemplates
end

function XCharacterConfigs.GetCharSkillLevelEffectTemplates()
    return CharSkillLevelEffectDict
end

local function GetCharLiberationConfig(characterId, growUpLevel)
    local config = CharLiberationTemplates[tonumber(characterId)]
    if not config then
        return
    end

    config = config[growUpLevel]
    if not config then
        return
    end

    return config
end

function XCharacterConfigs.GetCharLiberationLevelModelId(characterId, growUpLevel)
    local config = GetCharLiberationConfig(characterId, growUpLevel)
    return config and config.ModelId
end

function XCharacterConfigs.GetCharLiberationLevelModelId(characterId, growUpLevel)
    local config = GetCharLiberationConfig(characterId, growUpLevel)
    return config and config.ModelId
end

function XCharacterConfigs.GetCharLiberationLevelEffectRootAndPath(characterId, growUpLevel)
    local config = GetCharLiberationConfig(characterId, growUpLevel)
    if not config then return end
    return config.EffectRootName, config.EffectPath
end

function XCharacterConfigs.GetCharMaxLiberationSkillId(characterId)
    return CharMaxLiberationSkillIdDic[characterId]
end