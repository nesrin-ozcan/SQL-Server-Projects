
-----------DATA CLEANING OF NashvilleHousing DATASET---------------


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- If it doesn't Update properly
select SaleDate, SaleDateConverted from NashvilleHousing

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Make a SELF-JOIN to show PropertyAddress s that have the same ParcelID s

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Update the column "PropertyAddress" and fill null values with the "PropertyAddress" values of another row
--that has the same "ParcelID" and different "UniqueID"

Update nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing nh1
JOIN PortfolioProject.dbo.NashvilleHousing nh2
	on nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
Where nh1.PropertyAddress is null

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID


--Parse the PropertyAddress values into two Address columns

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--It is correctly parsed. Let's change the table with respect to this manipulation
--Add two new columns for address

Alter table  PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255), PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
Set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
    PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 

select  PropertySplitAddress, PropertySplitCity  from PortfolioProject..NashvilleHousing

--Parse "OwnerAddress" column



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing
 where OwnerAddress is not null

Alter table  PortfolioProject.dbo.NashvilleHousing
Add OwnerPlitAddress Nvarchar(255), OwnerSplitCity Nvarchar(255), OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
Set OwnerPlitAddress =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select OwnerPlitAddress , OwnerSplitCity , OwnerSplitState from  PortfolioProject..NashvilleHousing 


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicate 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing --order by ParcelID
)
delete From RowNumCTE Where row_num > 1 

---DELETE UNUSED COLUMNS

Select * From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




